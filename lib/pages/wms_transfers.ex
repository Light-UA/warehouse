defmodule EXO.WMS.Transfers do
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
          NITRO.panel(class: :column20, body: "ID зброї"),
          NITRO.panel(class: :column20, body: "Звідки"),
          NITRO.panel(class: :column30, body: "Куди"),
          NITRO.panel(class: :column20, body: "Статус"),
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

    records = :kvs.all(~c"/wms/transfers")

    Enum.each(records, fn order ->
      id = EXO.wms_transfer(order, :id)
      :nitro.insert_bottom(:tableRow, WMS.TransferOrder.Row.new(id, order, []))
    end)
  end

  def next_transfer_order_id() do
    existing_numbers =
      :kvs.all(~c"/wms/transfers")
      |> Enum.map(fn transfer ->
        transfer
        |> EXO.wms_transfer(:id)
        |> :nitro.to_binary()
        |> String.trim()
      end)
      |> Enum.filter(fn id ->
        String.starts_with?(id, "TO-")
      end)
      |> Enum.map(fn id ->
        id
        |> String.replace("TO-", "")
        |> String.to_integer()
      end)

    next_number =
      case existing_numbers do
        [] -> 101
        numbers -> Enum.max(numbers) + 1
      end

    "TO-" <> Integer.to_string(next_number)
  end

  def normalize_id(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
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

  def update_weapon_location(weapon_id, new_location) do
    weapon = WMS.WeaponRules.find_weapon(weapon_id)

    if weapon != nil do
      updated_weapon =
        EXO.wms_weapon(
          weapon,
          storage_location: new_location
        )

      :kvs.remove(weapon, ~c"/wms/weapons")
      :kvs.append(updated_weapon, ~c"/wms/weapons")
    end
  end

  def update_weapon_status(weapon_id, new_status) do
    weapon = WMS.WeaponRules.find_weapon(weapon_id)

    if weapon != nil do
      updated_weapon =
        EXO.wms_weapon(
          weapon,
          status: new_status
        )

      :kvs.remove(weapon, ~c"/wms/weapons")
      :kvs.append(updated_weapon, ~c"/wms/weapons")
    end
  end

  def current_time() do
    DateTime.utc_now()
    |> DateTime.to_iso8601()
  end

  def create_weapon_event_from_transfer(transfer, new_status) do
    if new_status == "Delivered" do
      event =
        EXO.wms_weapon_event(
          id: :kvs.seq([], []),
          weapon: EXO.wms_transfer(transfer, :weapon),
          event_type: "TRANSFER_COMPLETED",
          actor: "Logistics",
          event_status: "completed",
          from_storage: EXO.wms_transfer(transfer, :from_storage),
          to_storage: EXO.wms_transfer(transfer, :to_storage),
          related_service_order: "",
          created_at: current_time()
        )

      :kvs.append(event, ~c"/wms/weapon_events")
    end
  end

  def build_form() do
    :nitro.clear(:frms)

    :nitro.insert_bottom(
      :frms,
      NITRO.panel(id: :transfer_error, body: [])
    )

    mod = WMS.TransferOrder.Form

    form = mod.new(:none, mod.id(), [])

    :nitro.insert_bottom(:frms, :form.new(form, mod.id(), []))
  end

  def new_status("Init"), do: "Transit"
  def new_status("Transit"), do: "Delivered"
  def new_status("Delivered"), do: "Delivered"
  def new_status(_), do: "Init"

  def event({:CreateTO, _form}) do
    id = next_transfer_order_id()
    weapon = :nitro.to_binary(:nitro.q(:weapon_wms_transfer_none))
    from_storage = :nitro.to_binary(:nitro.q(:from_storage_wms_transfer_none))
    to_storage = :nitro.to_binary(:nitro.q(:to_storage_wms_transfer_none))

    cond do
      weapon != [] and not WMS.WeaponRules.weapon_exists?(weapon) ->
        WMS.UI.show_error(:transfer_error,
        "Помилка: зброї з таким ID не існує"
        )

      weapon != [] and not WMS.WeaponRules.available_for_transfer?(weapon) ->
        WMS.UI.show_error(
          :transfer_error,
          "Помилка: заявку на переміщення можна створити тільки для зброї зі статусом 'На озброєнні'"
        )

      true ->
        order =
          EXO.wms_transfer(
            id: id,
            weapon: weapon,
            from_storage: from_storage,
            to_storage: to_storage,
            transfer_status: "Init"
          )

        :kvs.append(order, ~c"/wms/transfers")
        :nitro.insert_bottom(:tableRow, WMS.TransferOrder.Row.new(id, order, []))
        # Init BPE Process
        :bpe.start(WMS.BPE.LogisticsOrder.def(), [])
        :nitro.hide(:frms)
        :nitro.show(:ctrl)
    end
  end

  def next_status("Init"), do: "Transit"
  def next_status("Transit"), do: "Delivered"
  def next_status("Delivered"), do: "Delivered"
  def next_status(_), do: "Init"

  def event({:NextStatus, id}) do
    transfer =
      :kvs.all(~c"/wms/transfers")
      |> Enum.find(fn transfer ->
        normalize_id(EXO.wms_transfer(transfer, :id)) == normalize_id(id)
      end)

    if transfer != nil do
      current_status = EXO.wms_transfer(transfer, :transfer_status)
      new_status = next_status(:nitro.to_binary(current_status))

      weapon_id = EXO.wms_transfer(transfer, :weapon)
      to_storage = EXO.wms_transfer(transfer, :to_storage)

      updated_transfer = EXO.wms_transfer(transfer, transfer_status: new_status)

      :kvs.remove(transfer, ~c"/wms/transfers")
      :kvs.append(updated_transfer, ~c"/wms/transfers")

      case new_status do
        "Transit" ->
          update_weapon_status(weapon_id, "transfer")

        "Delivered" ->
          update_weapon_location(weapon_id, to_storage)
          update_weapon_status(weapon_id, "active")
          create_weapon_event_from_transfer(transfer, new_status)

        _ ->
          :ok
      end

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
