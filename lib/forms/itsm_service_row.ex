defmodule ITSM.Service.Row do
  require EXO
  require NITRO

  def doc(), do: "Рядок таблиці ІТ-сервісів"
  def id, do: EXO.itsm_service()

  def new(name, service, _) do
    id = EXO.itsm_service(service, :id)
    name_str = EXO.itsm_service(service, :name)
    desc_str = EXO.itsm_service(service, :description)
    owner_str = EXO.itsm_service(service, :owner)
    status_str = EXO.itsm_service(service, :status)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, style: "width: 10%; word-break: break-all; white-space: normal;", body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, style: "width: 15%; white-space: normal;", body: :nitro.to_binary(name_str)),
        NITRO.panel(class: :column20, style: "width: 55%; white-space: normal;", body: :nitro.to_binary(desc_str)),
        NITRO.panel(class: :column12, style: "width: 12%; white-space: normal;", body: :nitro.to_binary(owner_str)),
        NITRO.panel(class: :column10, style: "width: 8%; white-space: normal;", body: :nitro.to_binary(status_str))
      ]
    )
  end
end
