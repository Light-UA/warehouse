defmodule ITSM.Incident.Row do
  require EXO
  require NITRO

  def doc(), do: "Рядок таблиці інцидентів"
  def id, do: EXO.itsm_incident()

  def new(name, incident, _) do
    id = EXO.itsm_incident(incident, :id)
    service = EXO.itsm_incident(incident, :service)
    priority = EXO.itsm_incident(incident, :priority)
    status = EXO.itsm_incident(incident, :status)
    assignee = EXO.itsm_incident(incident, :assignee)
    desc = EXO.itsm_incident(incident, :description)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(service)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(priority)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(status)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(assignee)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(desc))
      ]
    )
  end
end
