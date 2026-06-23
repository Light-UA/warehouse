defmodule EXO.WMS.ServiceEvents do
  require EXO
  require NITRO
  require Logger

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.insert_top(:tableHead, header())
    :nitro.clear(:ctrl)

    build_form()

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :creator,
        body: "Додати сервісну подію",
        postback: :create,
        class: [:button, :sgreen]
      )
    )

    :nitro.hide(:frms)

    :lists.map(
      fn x ->
        :nitro.insert_top(
          :tableRow,
          WMS.ServiceEvent.Row.new(:form.atom([:row, EXO.wms_service_event(x, :id)]), x, [])
        )
      end,
      :kvs.all(~c"/wms/service_events")
    )
  end

  def build_form() do
    :nitro.clear(:frms)

    :nitro.insert_bottom(
      :frms,
      NITRO.panel(id: :service_event_error, body: [])
    )

    mod = WMS.ServiceEvent.Form
    form = :form.new(mod.new(:none, mod.id(), []), mod.id(), [])
    :nitro.insert_bottom(:frms, form)
  end

  def event(:create) do
    build_form()
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
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
      weapon_id =
        weapon
        |> EXO.wms_weapon(:id)
        |> normalize_id()

      weapon_id == wanted_id
    end)
  end

  def part_installed_in_weapon(part_serial_number, weapon_id) do
    wanted_part = normalize_id(weapon_id)
    wanted_weapon = normalize_id(weapon_id)

    :kvs.all(~c"/wms/parts")
    |> Enum.any?(fn part ->
      part_serial =
        part
        |> EXO.wms_part(:serial_number)
        |> normalize_id()

      installed_weapon =
        part
        |> EXO.wms_part(:installed_in_weapon)
        |> normalize_id()

      part_serial == wanted_part and installed_weapon == wanted_weapon
    end)
  end

  def part_exists(part_serial_number) do
    wanted_serial_number = normalize_id(part_serial_number)

    :kvs.all(~c"/wms/parts")
    |> Enum.any?(fn part ->
      serial_number =
        part
        |> EXO.wms_part(:serial_number)
        |> normalize_id()

      serial_number == wanted_serial_number
    end)
  end

  def service_order_exists(service_order_id) do
    wanted_id = normalize_id(service_order_id)

    :kvs.all(~c"/wms/service_orders")
    |> Enum.any?(fn order ->
      order_id =
        order
        |> EXO.wms_service_order(:id)
        |> normalize_id()

      order_id == wanted_id
    end)
  end

  def event({:SaveServiceEvent, _}) do
    service_order = :service_order_wms_service_event_none |> :nitro.q()
    weapon = :weapon_wms_service_event_none |> :nitro.q()
    event_type = :event_type_wms_service_event_none |> :nitro.q()
    actor = :actor_wms_service_event_none |> :nitro.q()
    event_status = :event_status_wms_service_event_none |> :nitro.q()
    condition = :condition_wms_service_event_none |> :nitro.q()
    required_action = :required_action_wms_service_event_none |> :nitro.q()
    result = :result_wms_service_event_none |> :nitro.q()
    old_part = :old_part_wms_service_event_none |> :nitro.q()
    new_part = :new_part_wms_service_event_none |> :nitro.q()

    cond do
      service_order !=[] and not service_order_exists(service_order)->
        WMS.UI.show_error(:service_event_error, "Помилка: сервісного наряду з таким ID не існує")
      weapon != [] and not weapon_exists(weapon) ->
        WMS.UI.show_error(:service_event_error, "Помилка: зброї з таким ID не існує")
      old_part != [] and not part_exists(old_part) ->
        WMS.UI.show_error(:service_event_error, "Помилка: старої деталі з таким серійним номером не існує")
      new_part != [] and not part_exists(new_part) ->
        WMS.UI.show_error(:service_event_error, "Помилка: нової деталі з таким серійним номером не існує")

      true ->
        id = :kvs.seq([], [])

        service_event =
          EXO.wms_service_event(
            id: id,
            service_order: service_order,
            weapon: weapon,
            event_type: event_type,
            actor: actor,
            event_status: event_status,
            condition: condition,
            required_action: required_action,
            result: result,
            old_part: old_part,
            new_part: new_part
          )

        :kvs.append(service_event, ~c"/wms/service_events")

        :nitro.insert_top(
          :tableRow,
          WMS.ServiceEvent.Row.new(:form.atom([:row, id]), service_event, [])
        )

        build_form()

        :nitro.hide(:frms)
        :nitro.show(:ctrl)
    end
  end

  def event({:Close, _}) do
    build_form()
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, body: "ID"),
        NITRO.panel(class: :column20, body: "Сервісний наряд"),
        NITRO.panel(class: :column20, body: "ID зброї"),
        NITRO.panel(class: :column20, body: "Тип події"),
        NITRO.panel(class: :column20, body: "Виконавець"),
        NITRO.panel(class: :column20, body: "Статус події"),
        NITRO.panel(class: :column20, body: "Стан"),
        NITRO.panel(class: :column20, body: "Необхідна дія"),
        NITRO.panel(class: :column20, body: "Результат"),
        NITRO.panel(class: :column20, body: "Стара деталь"),
        NITRO.panel(class: :column20, body: "Нова деталь")
      ]
    )
  end
end
