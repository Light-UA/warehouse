defmodule EXO.WMS.Services do
  require EXO
  require NITRO
  require FORM

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.clear(:ctrl)
    :nitro.clear(:frms)

    :nitro.insert_top(
      :tableHead,
      NITRO.panel(
        id: :header,
        class: :th,
        body: [
          NITRO.panel(class: :column10, body: "ID"),
          NITRO.panel(class: :column10, body: "ID зброї"),
          NITRO.panel(class: :column20, body: "Причина"),
          NITRO.panel(class: :column10, body: "Статус"),
          NITRO.panel(class: :column20, body: "Результат"),
          NITRO.panel(class: :column20, body: "Прийняв"),
          NITRO.panel(class: :column10, body: "Дія")
        ]
      )
    )

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :new_order,
        body: "Новий наряд",
        postback: :new_order,
        class: [:button, :sgreen]
      )
    )

    :nitro.hide(:frms)

    records = :kvs.all(~c"/wms/service_orders")

    Enum.each(records, fn order ->
      id = EXO.wms_service_order(order, :id)
      :nitro.insert_bottom(:tableRow, WMS.ServiceOrder.Row.new(id, order, []))
    end)
  end

  def next_service_order_id() do
    existing_numbers =
      :kvs.all(~c"/wms/service_orders")
      |> Enum.map(fn order ->
        order
        |> EXO.wms_service_order(:id)
        |> :nitro.to_binary()
        |> String.trim()
      end)
      |> Enum.filter(fn id ->
        String.starts_with?(id, "SO-")
      end)
      |> Enum.map(fn id ->
        id
        |> String.replace("SO-", "")
        |> String.to_integer()
      end)

    next_number =
      case existing_numbers do
        [] -> 101
        numbers -> Enum.max(numbers) + 1
      end

    "SO-" <> Integer.to_string(next_number)
  end

  def normalize_id(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
  end

  def current_time() do
    DateTime.utc_now()
    |> DateTime.to_iso8601()
  end

  def weapon_exists(weapon_id) do
    wanted_id = normalize_id(weapon_id)

    :kvs.all(~c"/wms/weapons")
    |> Enum.any?(fn weapon ->
      current_id =
        weapon
        |> EXO.wms_weapon(:id)
        |> normalize_id()

      current_id == wanted_id
    end)
  end

  def update_weapon_status(weapon_id, new_status) do
    weapon =
      :kvs.all(~c"/wms/weapons")
      |> Enum.find(fn weapon ->
        normalize_id(EXO.wms_weapon(weapon, :id)) == normalize_id(weapon_id)
      end)

    if weapon != nil do
      updated_weapon = EXO.wms_weapon(weapon, status: new_status)

      :kvs.remove(weapon, ~c"/wms/weapons")
      :kvs.append(updated_weapon, ~c"/wms/weapons")
    end
  end

  def create_weapon_event_from_service_order(order, new_status) do
    case new_status do
      "Repair" ->
        event =
          EXO.wms_weapon_event(
            id: :kvs.seq([], []),
            weapon: EXO.wms_service_order(order, :weapon),
            event_type: "REPAIR_STARTED",
            actor: EXO.wms_service_order(order, :received_by),
            event_status: "started",
            from_storage: "",
            to_storage: "",
            related_service_order: EXO.wms_service_order(order, :id),
            related_part: "",
            created_at: current_time()
          )

      "Init" ->
        event =
          EXO.wms_weapon_event(
            id: :kvs.seq([], []),
            weapon: EXO.wms_service_order(order, :weapon),
            event_type: "SERVICE_ORDER_CREATED",
            actor: EXO.wms_service_order(order, :received_by),
            event_status: "created",
            from_storage: "",
            to_storage: "",
            related_service_order: EXO.wms_service_order(order, :id),
            related_part: "",
            created_at: current_time()
          )

        :kvs.append(event, ~c"/wms/weapon_events")

      _ ->
        :ok
    end
  end

  def build_form() do
    :nitro.clear(:frms)

    :nitro.insert_bottom(
      :frms,
      NITRO.panel(id: :service_order_error, body: [])
    )

    mod = WMS.ServiceOrder.Form
    form = mod.new(:none, mod.id(), [])
    :nitro.insert_bottom(:frms, :form.new(form, mod.id(), []))
  end

  def next_status("Init"), do: "Diagnostic"
  def next_status("Diagnostic"), do: "Repair"
  def next_status("Repair"), do: "Testing"
  def next_status("Testing"), do: "Ready"
  def next_status("Ready"), do: "Ready"
  def next_status(_), do: "Init"

  def event({:CreateSO, _form}) do
    id = next_service_order_id()
    weapon = :nitro.to_binary(:nitro.q(:weapon_wms_service_order_none))
    reason = :nitro.to_binary(:nitro.q(:reason_wms_service_order_none))
    received_by = :nitro.to_binary(:nitro.q(:received_by_wms_service_order_none))

    cond do
      weapon != [] and not WMS.WeaponRules.weapon_exists?(weapon) ->
        WMS.UI.show_error(:service_order_error, "Помилка: зброї з таким ID не існує")

      weapon != [] and not WMS.WeaponRules.available_for_service?(weapon) ->
        WMS.UI.show_error(:service_order_error,
          "Помилка: сервісний наряд можна створити тільки для зброї зі статусом 'На озброєнні'"
        )

      true ->
        order =
          EXO.wms_service_order(
            id: id,
            weapon: weapon,
            reason: reason,
            received_by: received_by,
            service_status: "Init",
            result: ""
          )

        :kvs.append(order, ~c"/wms/service_orders")
        create_weapon_event_from_service_order(order, "Init")
        :nitro.insert_bottom(:tableRow, WMS.ServiceOrder.Row.new(id, order, []))

        :bpe.start(WMS.BPE.ServiceOrder.def(), [])

        build_form()

        :nitro.hide(:frms)
        :nitro.show(:ctrl)
    end
  end

  def event({:NextStatus, id}) do
    order =
      :kvs.all(~c"/wms/service_orders")
      |> Enum.find(fn order ->
        normalize_id(EXO.wms_service_order(order, :id)) == normalize_id(id)
      end)

    if order != nil do
      current_status = EXO.wms_service_order(order, :service_status)
      new_status = next_status(:nitro.to_binary(current_status))

      weapon_id = EXO.wms_service_order(order, :weapon)
      updated_order = EXO.wms_service_order(order, service_status: new_status)

      case new_status do
        "Repair" ->
          update_weapon_status(weapon_id, "repair")

        "Ready" ->
          update_weapon_status(weapon_id, "active")

        _ ->
          :ok
      end

      create_weapon_event_from_service_order(order, new_status)

      :kvs.remove(order, ~c"/wms/service_orders")
      :kvs.append(updated_order, ~c"/wms/service_orders")

      event(:init)
    end
  end

  def event(:new_order) do
    :nitro.hide(:ctrl)
    build_form()
    :nitro.show(:frms)
  end

  def event({:Close, _}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(_), do: :ok
end
