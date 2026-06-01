defmodule EXO.ITSM.Portal do
  require EXO
  require NITRO
  require Logger
  require BPE

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.clear(:myServices)
    :nitro.clear(:outages)
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)

    # Resolve client session
    bin = :nitro.qc(:p)
    p = if is_binary(bin), do: bin, else: "3"
    clients = :kvs.all(~c"/exo/clients")
    client = Enum.find(clients, fn x -> :nitro.to_binary(EXO.client(x, :phone)) == p end)

    if is_nil(client) do
      :nitro.insert_bottom(:myServices, "Користувача не знайдено.")
    else
      _client_id = EXO.client(client, :id)
      _client_name = EXO.client(client, :names)
      client_phone = EXO.client(client, :phone)

      # 1. Populate Active Services
      services = :kvs.all(~c"/itsm/services")
      
      services_list = Enum.map(services, fn s ->
        name = EXO.itsm_service(s, :name)
        status = EXO.itsm_service(s, :status)
        NITRO.panel(
          style: "padding: 8px; margin: 4px 0; background: #f9f9f9; border-radius: 4px; border-left: 3px solid #4CAF50;",
          body: [
            NITRO.panel(style: "font-weight: bold;", body: :nitro.to_binary(name)),
            NITRO.panel(style: "font-size: 0.85em; color: #666;", body: "Статус: #{status}")
          ]
        )
      end)
      :nitro.insert_bottom(:myServices, services_list)

      # 2. Render Outages
      incidents = :kvs.all(~c"/itsm/incidents")
      active_incidents = Enum.filter(incidents, fn inc ->
        EXO.itsm_incident(inc, :status) in [:new, :accepted, :in_progress, :escalated]
      end)

      case active_incidents do
        [] ->
          :nitro.insert_bottom(
            :outages,
            NITRO.panel(
              style: "background: #E8F5E9; color: #2E7D32; padding: 12px; border-radius: 4px;",
              body: "✔ Усі системи працюють у штатному режимі. Збоїв не виявлено."
            )
          )
        _ ->
          outage_alerts = Enum.map(active_incidents, fn inc ->
            service_id = EXO.itsm_incident(inc, :service)
            # Find service name
            service_record = Enum.find(services, fn s -> :nitro.to_binary(EXO.itsm_service(s, :id)) == :nitro.to_binary(service_id) end)
            service_name = if service_record, do: EXO.itsm_service(service_record, :name), else: "ІТ-Сервіс"

            NITRO.panel(
              style: "background: #FFEBEE; color: #C62828; padding: 12px; border-radius: 4px; margin-bottom: 8px;",
              body: "⚠ Спостерігається збій у роботі послуги: '#{service_name}'. Наші інженери працюють над відновленням."
            )
          end)
          :nitro.insert_bottom(:outages, outage_alerts)
      end

      # 3. Form Setup
      mod = ITSM.Ticket.Form
      form = :form.new(mod.new(client_phone, mod.id(), []), mod.id(), [])
      :nitro.insert_bottom(:frms, form)
      :nitro.hide(:frms)

      :nitro.insert_bottom(
        :ctrl,
        NITRO.link(id: :creator, body: "Нове звернення", postback: :create, class: [:button, :sgreen])
      )

      # 4. Render user's tickets
      :nitro.insert_top(:tableHead, header())
      all_reqs = :kvs.all(~c"/itsm/reqs")
      my_reqs = Enum.filter(all_reqs, fn req -> :nitro.to_binary(EXO.itsm_req(req, :initiator)) == :nitro.to_binary(client_phone) end)

      :lists.map(
        fn r ->
          :nitro.insert_top(
            :tableRow,
            ticket_row(r, services)
          )
        end,
        my_reqs
      )
    end
  end

  def event(:create) do
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
  end

  def event({:CreateTicket, _}) do
    bin = :nitro.qc(:p)
    p = if is_binary(bin), do: bin, else: "3"
    
    service_val = :service_itsm_req_none |> :nitro.q()
    title_val = :title_itsm_req_none |> :nitro.q()
    desc_val = :description_itsm_req_none |> :nitro.q()
    _priority_val = :priority_itsm_req_none |> :nitro.q()
    id = :kvs.seq([], [])
    date = :calendar.now_to_datetime(:erlang.timestamp())

    req = EXO.itsm_req(
      id: id,
      initiator: p,
      service: service_val,
      title: title_val,
      description: desc_val,
      status: :registered,
      created_at: date,
      closed_at: []
    )
    :kvs.append(req, ~c"/itsm/reqs")

    # Start a BPE workflow for this ticket
    try do
      {:ok, proc_id} = :bpe.start(BPE.Incident.def(), [req])
      Logger.info("BPE Incident process started for ticket: #{id} -> Proc: #{proc_id}")
    rescue
      err -> Logger.warning("BPE workflow start failed: #{inspect(err)}")
    end

    # Refresh page
    event(:init)
  end

  def event({:Close, []}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(x) do
    Logger.info("Portal event: #{inspect(x)}")
  end

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, body: "Номер"),
        NITRO.panel(class: :column20, body: "Сервіс"),
        NITRO.panel(class: :column40, body: "Тема"),
        NITRO.panel(class: :column10, body: "Пріоритет"),
        NITRO.panel(class: :column20, body: "Статус")
      ]
    )
  end

  def ticket_row(req_rec, services) do
    id = EXO.itsm_req(req_rec, :id)
    service_id = EXO.itsm_req(req_rec, :service)
    title = EXO.itsm_req(req_rec, :title)
    priority = :low # default or user priority
    status = EXO.itsm_req(req_rec, :status)

    service_record = Enum.find(services, fn s -> :nitro.to_binary(EXO.itsm_service(s, :id)) == :nitro.to_binary(service_id) end)
    service_name = if service_record, do: EXO.itsm_service(service_record, :name), else: :nitro.to_binary(service_id)

    NITRO.panel(
      id: :form.atom([:tr, id]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(service_name)),
        NITRO.panel(class: :column40, body: :nitro.to_binary(title)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(priority)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(status))
      ]
    )
  end
end
