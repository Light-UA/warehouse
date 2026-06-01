defmodule EXO.ITSM.Incidents do
  require EXO
  require NITRO
  require Logger

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.insert_top(:tableHead, header())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)

    mod = ITSM.Incident.Form
    form = :form.new(mod.new(mod, mod.id(), []), mod.id(), [])
    :nitro.insert_bottom(:frms, form)

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(id: :creator, body: "Зареєструвати інцидент", postback: :create, class: [:button, :sgreen])
    )

    :nitro.hide(:frms)

    :lists.map(
      fn x ->
        :nitro.insert_top(
          :tableRow,
          ITSM.Incident.Row.new(:form.atom([:row, EXO.itsm_incident(x, :id)]), x, [])
        )
      end,
      :kvs.all(~c"/itsm/incidents")
    )
  end

  def event(:create) do
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
  end

  def event({:CreateIncident, _}) do
    req = :req_itsm_incident_none |> :nitro.q()
    service = :service_itsm_incident_none |> :nitro.q()
    priority = :priority_itsm_incident_none |> :nitro.q()
    status = :status_itsm_incident_none |> :nitro.q()
    assignee = :assignee_itsm_incident_none |> :nitro.q()
    desc = :description_itsm_incident_none |> :nitro.q()
    id = :kvs.seq([], [])

    incident = EXO.itsm_incident(
      id: id,
      req: req,
      service: service,
      priority: priority,
      status: status,
      assignee: assignee,
      description: desc
    )
    :kvs.append(incident, ~c"/itsm/incidents")

    row = ITSM.Incident.Row.new(:form.atom([:row, id]), incident, [])
    :nitro.insert_top(:tableRow, :form.new(row, incident, []))

    # Trigger BPE process creation
    try do
      :bpe.start(BPE.Incident.def(), [incident])
    rescue
      err -> Logger.warning("BPE start failed for incident: #{inspect(err)}")
    end

    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event({:Close, []}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(x) do
    Logger.info("Incidents event: #{inspect(x)}")
  end

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, body: "Номер"),
        NITRO.panel(class: :column20, body: "Сервіс"),
        NITRO.panel(class: :column10, body: "Пріоритет"),
        NITRO.panel(class: :column20, body: "Статус"),
        NITRO.panel(class: :column20, body: "Виконавець"),
        NITRO.panel(class: :column20, body: "Опис")
      ]
    )
  end
end
