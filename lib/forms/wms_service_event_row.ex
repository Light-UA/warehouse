defmodule WMS.ServiceEvent.Row do
  require EXO
  require NITRO
  require FORM

require EXO
  def id(), do: EXO.wms_service_event()

  def doc(), do: "Форма сервісної події (таблична частина)"

  def new(name, event, _) do
    id = EXO.wms_service_event(event, :id)
    service_order = EXO.wms_service_event(event, :service_order)
    weapon = EXO.wms_service_event(event, :weapon)
    event_type = EXO.wms_service_event(event, :event_type)
    actor = EXO.wms_service_event(event, :actor)
    event_status = EXO.wms_service_event(event, :event_status)
    result = EXO.wms_service_event(event, :result)
    condition = EXO.wms_service_event(event, :condition)
    required_action = EXO.wms_service_event(event, :required_action)
    old_part = EXO.wms_service_event(event, :old_part)
    new_part = EXO.wms_service_event(event, :new_part)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(service_order)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(weapon)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(event_type)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(actor)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(event_status)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(result)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(condition)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(required_action)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(old_part)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(new_part))
      ]
    )
  end
end
