defmodule ITSM.Change.Row do
  require EXO
  require NITRO

  def doc(), do: "Рядок таблиці запитів на зміни"
  def id, do: EXO.itsm_change()

  def new(name, change, _) do
    id = EXO.itsm_change(change, :id)
    service = EXO.itsm_change(change, :service)
    title = EXO.itsm_change(change, :title)
    risk = EXO.itsm_change(change, :risk_level)
    impact = EXO.itsm_change(change, :impact)
    status = EXO.itsm_change(change, :status)
    manager = EXO.itsm_change(change, :change_manager)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(service)),
        NITRO.panel(class: :column30, body: :nitro.to_binary(title)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(risk)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(impact)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(status)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(manager))
      ]
    )
  end
end
