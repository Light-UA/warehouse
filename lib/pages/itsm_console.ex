defmodule EXO.ITSM.Console do
  require EXO
  require NITRO
  require Logger
  require BPE

  def event(:init) do
    :nitro.clear(:ticketsQueue)
    :nitro.clear(:ticketDetail)
    :nitro.clear(:workflowActions)
    :nitro.clear(:clientBillingInfo)

    # 1. Render Tickets Queue
    reqs = :kvs.all(~c"/itsm/reqs")
    _services = :kvs.all(~c"/itsm/services")

    case reqs do
      [] ->
        :nitro.insert_bottom(:ticketsQueue, NITRO.panel(body: "Черга порожня."))
      _ ->
        queue = Enum.map(reqs, fn req ->
          id = EXO.itsm_req(req, :id)
          title = EXO.itsm_req(req, :title)
          status = EXO.itsm_req(req, :status)
          
          NITRO.panel(
            style: "padding: 10px; margin-bottom: 8px; background: #f9f9f9; border-radius: 4px; cursor: pointer; border-left: 4px solid #2196F3;",
            body: NITRO.link(
              postback: {:select_ticket, id},
              body: [
                NITRO.panel(style: "font-weight: bold; font-size: 0.9em;", body: "Звернення ##{id}"),
                NITRO.panel(style: "margin: 4px 0;", body: :nitro.to_binary(title)),
                NITRO.panel(style: "font-size: 0.8em; color: #E65100;", body: "Статус: #{status}")
              ]
            )
          )
        end)
        :nitro.insert_bottom(:ticketsQueue, queue)
    end
  end

  def event({:select_ticket, ticket_id}) do
    :nitro.clear(:ticketDetail)
    :nitro.clear(:workflowActions)
    :nitro.clear(:clientBillingInfo)

    reqs = :kvs.all(~c"/itsm/reqs")
    req = Enum.find(reqs, fn r -> :nitro.to_binary(EXO.itsm_req(r, :id)) == :nitro.to_binary(ticket_id) end)

    if req do
      initiator = EXO.itsm_req(req, :initiator)
      service_id = EXO.itsm_req(req, :service)
      title = EXO.itsm_req(req, :title)
      desc = EXO.itsm_req(req, :description)
      status = EXO.itsm_req(req, :status)

      # Get service name
      services = :kvs.all(~c"/itsm/services")
      service_record = Enum.find(services, fn s -> :nitro.to_binary(EXO.itsm_service(s, :id)) == :nitro.to_binary(service_id) end)
      service_name = if service_record, do: EXO.itsm_service(service_record, :name), else: :nitro.to_binary(service_id)

      # 1. Detail pane
      :nitro.insert_bottom(
        :ticketDetail,
        [
          NITRO.panel(style: "font-size: 1.2em; font-weight: bold; margin-bottom: 10px;", body: "##{ticket_id}: #{title}"),
          NITRO.panel(style: "margin-bottom: 5px;", body: [NITRO.span(style: "font-weight: bold;", body: "Сервіс: "), service_name]),
          NITRO.panel(style: "margin-bottom: 5px;", body: [NITRO.span(style: "font-weight: bold;", body: "Ініціатор (телефон): "), :nitro.to_binary(initiator)]),
          NITRO.panel(style: "margin-bottom: 15px;", body: [NITRO.span(style: "font-weight: bold;", body: "Поточний статус: "), :nitro.to_binary(status)]),
          NITRO.panel(style: "border-top: 1px solid #eee; padding-top: 10px; font-style: italic;", body: :nitro.to_binary(desc))
        ]
      )

      # 2. Find BPE Process and progress triggers
      all_procs = :kvs.all(~c"/bpe/proc")
      proc = Enum.find(all_procs, fn p ->
        docs = BPE.process(p, :docs)
        Enum.any?(docs, fn d -> 
          :erlang.element(1, d) == :itsm_req and 
          :nitro.to_binary(EXO.itsm_req(d, :id)) == :nitro.to_binary(ticket_id)
        end)
      end)

      if proc do
        proc_id = BPE.process(proc, :id)
        {_, current_task} = :bpe.current_task(proc)

        :nitro.insert_bottom(
          :workflowActions,
          [
            NITRO.panel(style: "margin-bottom: 15px; font-weight: bold;", body: "Поточний крок BPE: #{current_task}"),
            NITRO.panel(
              body: [
                NITRO.link(
                  postback: {:advance_bpe, proc_id, ticket_id},
                  class: [:button, :sgreen],
                  style: "margin-right: 10px;",
                  body: "Наступний крок (Advance)"
                ),
                NITRO.link(
                  postback: {:fail_bpe, proc_id, ticket_id},
                  class: [:button, :cancel],
                  body: "Ескалювати / Відхилити"
                )
              ]
            )
          ]
        )
      else
        :nitro.insert_bottom(:workflowActions, "BPE процес не знайдено для цього звернення.")
      end

      # 3. Load Client & Billing Sidebar
      clients = :kvs.all(~c"/exo/clients")
      client = Enum.find(clients, fn x -> :nitro.to_binary(EXO.client(x, :phone)) == :nitro.to_binary(initiator) end)

      if client do
        client_id = EXO.client(client, :id)
        names = EXO.client(client, :names)
        surnames = EXO.client(client, :surnames)
        phone = EXO.client(client, :phone)

        # Retrieve client account
        accounts = :kvs.all(~c"/exo/accounts")
        account = Enum.find(accounts, fn a -> :nitro.to_binary(EXO.account(a, :client)) == :nitro.to_binary(client_id) end)

        if account do
          iban = EXO.account(account, :iban)
          balance = EXO.account(account, :amount)

          :nitro.insert_bottom(
            :clientBillingInfo,
            [
              NITRO.panel(style: "font-weight: bold; margin-bottom: 8px;", body: "#{names} #{surnames}"),
              NITRO.panel(style: "font-size: 0.9em; margin-bottom: 4px;", body: "тел: #{phone}"),
              NITRO.panel(style: "font-size: 0.9em; margin-bottom: 8px;", body: "IBAN: #{iban}"),
              NITRO.panel(
                style: "font-size: 1.3em; color: #2E7D32; font-weight: bold; margin-bottom: 15px; border-top: 1px solid #eee; padding-top: 8px;",
                body: "Баланс: #{balance} UAH"
              ),
              NITRO.link(
                postback: {:issue_refund, client_id, ticket_id},
                class: [:button, :sgreen],
                style: "width: 100%; display: block; text-align: center; box-sizing: border-box;",
                body: "Компенсація за SLA (1000₴)"
              )
            ]
          )
        else
          :nitro.insert_bottom(:clientBillingInfo, "Рахунок білінгу не знайдено.")
        end
      else
        :nitro.insert_bottom(:clientBillingInfo, "Співрозмовника не знайдено.")
      end
    end
  end

  def event({:advance_bpe, proc_id, ticket_id}) do
    # Advance BPE process
    try do
      :bpe.next(proc_id)
      
      # Update req status based on BPE progress
      proc = :bpe.proc(proc_id)
      {_, task} = :bpe.current_task(proc)
      
      req_status = case :nitro.to_binary(task) do
        "Triaje" -> :under_review
        "Work" -> :in_progress
        "Resolve" -> :resolved
        "Closed" -> :closed
        _ -> :in_progress
      end

      # Save status update
      reqs = :kvs.all(~c"/itsm/reqs")
      req_rec = Enum.find(reqs, fn r -> :nitro.to_binary(EXO.itsm_req(r, :id)) == :nitro.to_binary(ticket_id) end)
      if req_rec do
        updated_req = EXO.itsm_req(req_rec, status: req_status)
        # In KVS we append updated record to list
        :kvs.append(updated_req, ~c"/itsm/reqs")
      end
    rescue
      err -> Logger.warning("BPE Next failed: #{inspect(err)}")
    end

    event({:select_ticket, ticket_id})
  end

  def event({:fail_bpe, proc_id, ticket_id}) do
    try do
      # Trigger escalation branch
      :bpe.next(proc_id, "Escalate")
      
      reqs = :kvs.all(~c"/itsm/reqs")
      req_rec = Enum.find(reqs, fn r -> :nitro.to_binary(EXO.itsm_req(r, :id)) == :nitro.to_binary(ticket_id) end)
      if req_rec do
        updated_req = EXO.itsm_req(req_rec, status: :under_review)
        :kvs.append(updated_req, ~c"/itsm/reqs")
      end
    rescue
      err -> Logger.warning("BPE Escalate failed: #{inspect(err)}")
    end

    event({:select_ticket, ticket_id})
  end

  def event({:issue_refund, client_id, ticket_id}) do
    accounts = :kvs.all(~c"/exo/accounts")
    account = Enum.find(accounts, fn a -> :nitro.to_binary(EXO.account(a, :client)) == :nitro.to_binary(client_id) end)

    if account do
      current_amount = EXO.account(account, :amount)
      
      # Issue refund transaction (subtracting from balance or crediting back)
      # Let's credit back 1000 UAH
      new_amount = current_amount + 1000
      updated_account = EXO.account(account, amount: new_amount)
      
      # Save back to database
      :kvs.append(updated_account, ~c"/exo/accounts")

      # Create transaction record
      tx_id = :kvs.seq([], [])
      tx = EXO.transaction(
        id: tx_id,
        amount: 1000,
        description: "Компенсація за збій SLA по зверненню ##{ticket_id}"
      )
      :kvs.append(tx, ~c"/exo/transactions")

      Logger.info("SLA Breach refund issued for client #{client_id}: +1000 UAH. New balance: #{new_amount}")
    end

    event({:select_ticket, ticket_id})
  end

  def event(x) do
    Logger.info("Console event: #{inspect(x)}")
  end
end
