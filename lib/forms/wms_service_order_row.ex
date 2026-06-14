defmodule WMS.ServiceOrder.Row do
  require EXO
  require NITRO

  def id(), do: EXO.wms_service_order()
  def doc(), do: "Форма реєстрації сервісного замовлення (таблична частина)"

  def status_title("Init"), do: "Новий"
  def status_title("Diagnostic"), do: "Діагностика"
  def status_title("Repair"), do: "Ремонт"
  def status_title("Testing"), do: "Тестування"
  def status_title("Ready"), do: "Готово"
  def status_title("Completed"), do: "Завершено"
  def status_title(value), do: value

  def new(name, service_order, _) do
    id = EXO.wms_service_order(service_order, :id)
    weapon = EXO.wms_service_order(service_order, :weapon)
    reason = EXO.wms_service_order(service_order, :reason)
    status = EXO.wms_service_order(service_order, :service_status)
    result = EXO.wms_service_order(service_order, :result)
    received_by = EXO.wms_service_order(service_order, :received_by)

    status_value =
      status
      |> :nitro.to_binary()
      |> String.trim()

    action =
      case status_value do
        "Ready" ->
          NITRO.panel(
            style: "padding:8px 0;color:#6b7280;font-weight:600;",
            body: "✓ Завершено"
          )

        "Completed" ->
          NITRO.panel(
            style: "padding:8px 0;color:#6b7280;font-weight:600;",
            body: "✓ Завершено"
          )

        _ ->
          NITRO.link(
            body: "Далі",
            postback: {:NextStatus, id},
            class: [:button, :sgreen]
          )
      end

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(weapon)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(reason)),
        NITRO.panel(class: :column10, body: status_title(status_value)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(result)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(received_by)),
        NITRO.panel(class: :column10, body: action)
      ]
    )
  end
end
