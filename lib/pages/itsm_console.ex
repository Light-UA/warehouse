defmodule EXO.ITSM.Console do
  require EXO
  require NITRO
  require Logger
  require BPE

  # ── helpers ──────────────────────────────────────────────────────────────

  defp s(v), do: :nitro.to_binary(v)

  defp priority_color(:critical), do: "#C62828"
  defp priority_color(:high),     do: "#E65100"
  defp priority_color(:medium),   do: "#F57F17"
  defp priority_color(_),         do: "#37474F"

  defp status_label(:new),        do: "Новий"
  defp status_label(:accepted),   do: "Прийнято"
  defp status_label(:in_progress),do: "В роботі"
  defp status_label(:escalated),  do: "Ескальовано"
  defp status_label(:resolved),   do: "Вирішено"
  defp status_label(:closed),     do: "Закрито"
  defp status_label(x),           do: s(x)

  defp priority_label(:critical), do: "Критичний"
  defp priority_label(:high),     do: "Високий"
  defp priority_label(:medium),   do: "Середній"
  defp priority_label(:low),      do: "Низький"
  defp priority_label(x),         do: s(x)

  defp field_row(label, value) do
    NITRO.panel(
      style: "display: flex; gap: 8px; padding: 6px 0; border-bottom: 1px solid var(--border-color, #eee);",
      body: [
        NITRO.span(style: "font-weight: 600; min-width: 160px; color: var(--text-primary);", body: label),
        NITRO.span(style: "color: var(--text-secondary); flex: 1; word-break: break-word;", body: value)
      ]
    )
  end

  # ── init ─────────────────────────────────────────────────────────────────

  def event(:init) do
    :nitro.clear(:ticketsQueue)
    :nitro.clear(:ticketDetail)
    :nitro.clear(:workflowActions)
    :nitro.clear(:clientBillingInfo)

    incidents = :kvs.all(~c"/itsm/incidents")
    services  = :kvs.all(~c"/itsm/services")

      if incidents == [] do
        :nitro.insert_bottom(:ticketsQueue,
          NITRO.panel(style: "padding: 20px; color: #888; text-align: center;", body: "Інцидентів немає."))
      else
        :lists.map(fn inc ->
          id         = EXO.itsm_incident(inc, :id)
          service_id = EXO.itsm_incident(inc, :service)
          priority   = EXO.itsm_incident(inc, :priority)
          status     = EXO.itsm_incident(inc, :status)

          svc_rec  = Enum.find(services, fn sv ->
            :nitro.to_binary(EXO.itsm_service(sv, :id)) == :nitro.to_binary(service_id)
          end)
          svc_name = if svc_rec, do: EXO.itsm_service(svc_rec, :name), else: s(service_id)

          color = priority_color(priority)

          card = NITRO.panel(
            style: "padding: 10px 12px; margin-bottom: 8px; background: var(--bg-card, #fff); border-radius: 6px; cursor: pointer; border-left: 4px solid #{color}; box-shadow: 0 1px 3px rgba(0,0,0,.06);",
            body: NITRO.link(
              postback: {:select_incident, id},
              body: [
                NITRO.panel(style: "font-weight: 700; font-size: 0.88em; color: #{color};",
                  body: "INC-#{s(id)}"),
                NITRO.panel(style: "margin: 3px 0; font-size: 0.85em; color: var(--text-primary);",
                  body: s(svc_name)),
                NITRO.panel(style: "font-size: 0.78em; color: var(--text-secondary);",
                  body: "#{priority_label(priority)} · #{status_label(status)}")
              ]
            )
          )
          :nitro.insert_bottom(:ticketsQueue, card)
        end, incidents)
      end

  end

  # ── select incident ───────────────────────────────────────────────────────

  def event({:select_incident, inc_id}) do
    :nitro.clear(:ticketDetail)
    :nitro.clear(:workflowActions)
    :nitro.clear(:clientBillingInfo)

    incidents = :kvs.all(~c"/itsm/incidents")
    services  = :kvs.all(~c"/itsm/services")
    reqs      = :kvs.all(~c"/itsm/reqs")

    inc = Enum.find(incidents, fn i ->
      :nitro.to_binary(EXO.itsm_incident(i, :id)) == :nitro.to_binary(inc_id)
    end)

    if inc do
      # ── incident fields ──────────────────────────────────────────────────
      inc_req_id   = EXO.itsm_incident(inc, :req)
      service_id   = EXO.itsm_incident(inc, :service)
      priority     = EXO.itsm_incident(inc, :priority)
      status       = EXO.itsm_incident(inc, :status)
      assignee     = EXO.itsm_incident(inc, :assignee)
      description  = EXO.itsm_incident(inc, :description)
      resolution   = EXO.itsm_incident(inc, :resolution)
      slm_deadline = EXO.itsm_incident(inc, :slm_deadline)

      # ── resolve service name ─────────────────────────────────────────────
      svc_rec  = Enum.find(services, fn sv ->
        :nitro.to_binary(EXO.itsm_service(sv, :id)) == :nitro.to_binary(service_id)
      end)
      svc_name = if svc_rec, do: EXO.itsm_service(svc_rec, :name), else: s(service_id)
      svc_owner = if svc_rec, do: EXO.itsm_service(svc_rec, :owner), else: ""

      # ── resolve linked req (originator, contract) ────────────────────────
      req = Enum.find(reqs, fn r ->
        :nitro.to_binary(EXO.itsm_req(r, :id)) == :nitro.to_binary(inc_req_id)
      end)

      {req_title, req_status, originator} =
        if req do
          {EXO.itsm_req(req, :title), EXO.itsm_req(req, :status), EXO.itsm_req(req, :initiator)}
        else
          {"—", "—", ""}
        end

      # ── render detail panel ──────────────────────────────────────────────
      color = priority_color(priority)

      :nitro.insert_bottom(:ticketDetail, [
        NITRO.panel(
          style: "font-size: 1.15em; font-weight: 700; margin-bottom: 14px; padding-bottom: 10px; border-bottom: 2px solid #{color}; color: #{color};",
          body: "INC-#{s(inc_id)}"
        ),

        NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: #888; margin: 14px 0 6px;", body: "Інцидент"),
        field_row("ID інциденту:", "INC-#{s(inc_id)}"),
        field_row("Пов'язане звернення:", if(s(inc_req_id) == "", do: "—", else: "REQ-#{s(inc_req_id)}")),
        field_row("Назва звернення:", s(req_title)),
        field_row("Статус звернення:", status_label(req_status)),

        NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: #888; margin: 14px 0 6px;", body: "Сервіс"),
        field_row("Сервіс:", s(svc_name)),
        field_row("Власник сервісу:", s(svc_owner)),

        NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: #888; margin: 14px 0 6px;", body: "Параметри"),
        field_row("Пріоритет:", priority_label(priority)),
        field_row("Статус:", status_label(status)),
        field_row("Виконавець:", s(assignee)),
        field_row("Ініціатор (телефон):", s(originator)),
        field_row("SLM дедлайн:", if(slm_deadline == [], do: "—", else: s(slm_deadline))),

        NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: #888; margin: 14px 0 6px;", body: "Опис"),
        NITRO.panel(style: "background: var(--bg-primary, #f8fafc); border-radius: 6px; padding: 10px 12px; font-size: 0.9em; line-height: 1.5; color: var(--text-secondary);",
          body: if(s(description) == "", do: "—", else: s(description))),

        NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: #888; margin: 14px 0 6px;", body: "Резолюція"),
        NITRO.panel(style: "background: var(--bg-primary, #f8fafc); border-radius: 6px; padding: 10px 12px; font-size: 0.9em; line-height: 1.5; color: var(--text-secondary);",
          body: if(s(resolution) == "", do: "Не заповнено", else: s(resolution)))
      ])

      # ── BPE workflow — full history + actions ────────────────────────────
      if req do
        all_procs = :kvs.all(~c"/bpe/proc")
        req_id = EXO.itsm_req(req, :id)
        proc = Enum.find(all_procs, fn p ->
          docs = BPE.process(p, :docs)
          Enum.any?(docs, fn d ->
            :erlang.element(1, d) == :itsm_req and
            :nitro.to_binary(EXO.itsm_req(d, :id)) == :nitro.to_binary(req_id)
          end)
        end)

        if proc do
          proc_id = BPE.process(proc, :id)
          {_, current_task} = :bpe.current_task(proc)
          history = :bpe.hist(proc_id)

          # ── timeline header ──────────────────────────────────────────────
          :nitro.insert_bottom(:workflowActions,
            NITRO.panel(
              style: "display: grid; grid-template-columns: 36px 1fr 1fr 1fr; gap: 0; padding: 6px 8px; background: var(--bg-primary, #f8fafc); border-radius: 6px 6px 0 0; border: 1px solid var(--border-color, #e2e8f0); font-size: 0.75em; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: #94a3b8;",
              body: [
                NITRO.span(body: "№"),
                NITRO.span(body: "Крок / Перехід"),
                NITRO.span(body: "Час"),
                NITRO.span(body: "Документи")
              ]
            )
          )

          # ── history rows — one insert per step ──────────────────────────
          :lists.map(fn h ->
            step_id = BPE.hist(h, :id)
            task    = BPE.hist(h, :task)
            ts      = BPE.hist(h, :time)
            docs_h  = BPE.hist(h, :docs)

            step_no =
              try do
                step = :erlang.element(2, step_id)   # #step{id=N, ...}
                :nitro.to_binary(step)
              rescue _ -> "—"
              end

            step_name =
              case task do
                [] -> "—"
                _ ->
                  try do
                    src = BPE.sequenceFlow(task, :source)
                    :nitro.to_binary(src)
                  rescue _ ->
                    try do BPE.task(task, :name) |> :nitro.to_binary()
                    rescue _ -> :nitro.to_binary(task)
                    end
                  end
              end

            time_str =
              try do
                t = :erlang.element(2, ts)    # #ts{time=...}
                case t do
                  {{y,mo,d},{h,mi,s}} ->
                    "#{y}-#{String.pad_leading(to_string(mo),2,"0")}-#{String.pad_leading(to_string(d),2,"0")} #{String.pad_leading(to_string(h),2,"0")}:#{String.pad_leading(to_string(mi),2,"0")}:#{String.pad_leading(to_string(s),2,"0")}"
                  _ -> :nitro.to_binary(t)
                end
              rescue _ -> "—"
              end

            docs_str =
              try do
                doc_types = Enum.map(docs_h, fn d -> :nitro.to_binary(:erlang.element(1, d)) end)
                Enum.join(doc_types, ", ")
              rescue _ -> "—"
              end

            is_current = :nitro.to_binary(step_name) == :nitro.to_binary(current_task)

            row_bg = if is_current, do: "background: #e8f5e9;", else: "background: var(--bg-card, #fff);"
            row_weight = if is_current, do: "font-weight: 600;", else: ""

            :nitro.insert_bottom(:workflowActions,
              NITRO.panel(
                style: "display: grid; grid-template-columns: 36px 1fr 1fr 1fr; gap: 0; padding: 7px 8px; #{row_bg} border-left: 1px solid var(--border-color, #e2e8f0); border-right: 1px solid var(--border-color, #e2e8f0); border-bottom: 1px solid var(--border-color, #e2e8f0); font-size: 0.82em; #{row_weight} color: var(--text-secondary);",
                body: [
                  NITRO.span(style: "color: #94a3b8;", body: s(step_no)),
                  NITRO.span(body: s(step_name)),
                  NITRO.span(style: "font-family: monospace; font-size: 0.88em;", body: time_str),
                  NITRO.span(style: "color: #64748b;", body: docs_str)
                ]
              )
            )
          end, history)

          # ── current state label ──────────────────────────────────────────
          :nitro.insert_bottom(:workflowActions,
            NITRO.panel(
              style: "margin-top: 14px; padding: 8px 10px; background: #e8f5e9; border-radius: 6px; font-size: 0.85em; font-weight: 600; color: #2E7D32;",
              body: "▶ Поточний крок: #{s(current_task)}"
            )
          )

          # ── action buttons ───────────────────────────────────────────────
          :nitro.insert_bottom(:workflowActions,
            NITRO.panel(
              style: "margin-top: 10px; display: flex; gap: 10px;",
              body: [
                NITRO.link(
                  postback: {:advance_bpe, proc_id, req_id, inc_id},
                  class: [:button, :sgreen],
                  body: "Наступний крок"
                ),
                NITRO.link(
                  postback: {:fail_bpe, proc_id, req_id, inc_id},
                  class: [:button, :cancel],
                  body: "Ескалювати / Відхилити"
                )
              ]
            )
          )
        else
          :nitro.insert_bottom(:workflowActions,
            NITRO.panel(style: "color: #888; font-size: 0.9em;", body: "BPE процес не знайдено для пов'язаного звернення."))
        end
      else
        :nitro.insert_bottom(:workflowActions,
          NITRO.panel(style: "color: #888; font-size: 0.9em;", body: "Пов'язаного звернення (REQ) не знайдено."))
      end


      # ── client billing sidebar ────────────────────────────────────────────
      clients = :kvs.all(~c"/exo/clients")
      client = Enum.find(clients, fn x ->
        :nitro.to_binary(EXO.client(x, :phone)) == :nitro.to_binary(originator)
      end)

      if client do
        client_id = EXO.client(client, :id)
        names     = EXO.client(client, :names)
        surnames  = EXO.client(client, :surnames)
        phone     = EXO.client(client, :phone)
        status_c  = EXO.client(client, :status)
        type_c    = EXO.client(client, :type)

        accounts = :kvs.all(~c"/exo/accounts")
        account  = Enum.find(accounts, fn a ->
          :nitro.to_binary(EXO.account(a, :client)) == :nitro.to_binary(client_id)
        end)

        if account do
          iban      = EXO.account(account, :iban)
          balance   = EXO.account(account, :amount)
          program   = EXO.account(account, :program)
          edrpou    = EXO.account(account, :edrpou)
          acct_name = EXO.account(account, :name)
          acct_type = EXO.account(account, :type)
          acct_state= EXO.account(account, :state)

          :nitro.insert_bottom(:clientBillingInfo, [
            NITRO.panel(style: "font-weight: 700; font-size: 1.05em; margin-bottom: 10px; padding-bottom: 8px; border-bottom: 1px solid var(--border-color, #eee);",
              body: "#{names} #{surnames}"),

            NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; color: #888; margin: 10px 0 6px;", body: "Контакт"),
            field_row("Телефон:", s(phone)),
            field_row("Статус:", s(status_c)),
            field_row("Тип клієнта:", s(type_c)),

            NITRO.panel(style: "font-size: 0.8em; font-weight: 600; text-transform: uppercase; color: #888; margin: 10px 0 6px;", body: "Контракт / Рахунок"),
            field_row("Назва рахунку:", if(s(acct_name) == "", do: "—", else: s(acct_name))),
            field_row("IBAN:", s(iban)),
            field_row("Тариф (програма):", s(program)),
            field_row("ЄДРПОУ:", if(s(edrpou) == "", do: "—", else: s(edrpou))),
            field_row("Тип рахунку:", s(acct_type)),
            field_row("Стан рахунку:", s(acct_state)),

            NITRO.panel(
              style: "font-size: 1.4em; color: #2E7D32; font-weight: 700; margin: 14px 0 12px; text-align: center;",
              body: "#{balance} UAH"
            ),
            NITRO.link(
              postback: {:issue_refund, client_id, inc_id},
              class: [:button, :sgreen],
              style: "width: 100%; display: block; text-align: center; box-sizing: border-box;",
              body: "Компенсація за SLA (1000₴)"
            )
          ])
        else
          :nitro.insert_bottom(:clientBillingInfo,
            NITRO.panel(style: "color: #888; font-size: 0.9em;", body: "Рахунок не знайдено."))
        end
      else
        :nitro.insert_bottom(:clientBillingInfo,
          NITRO.panel(style: "color: #888; font-size: 0.9em;", body: "Клієнта не знайдено."))
      end
    end
  end

  # ── BPE advance ──────────────────────────────────────────────────────────

  def event({:advance_bpe, proc_id, req_id, inc_id}) do
    try do
      :bpe.next(proc_id)

      proc = :bpe.proc(proc_id)
      {_, task} = :bpe.current_task(proc)

      new_status = case :nitro.to_binary(task) do
        "Triaje" -> :under_review
        "Work"   -> :in_progress
        "Resolve"-> :resolved
        "Closed" -> :closed
        _        -> :in_progress
      end

      reqs = :kvs.all(~c"/itsm/reqs")
      req_rec = Enum.find(reqs, fn r ->
        :nitro.to_binary(EXO.itsm_req(r, :id)) == :nitro.to_binary(req_id)
      end)
      if req_rec do
        :kvs.append(EXO.itsm_req(req_rec, status: new_status), ~c"/itsm/reqs")
      end
    rescue
      err -> Logger.warning("BPE Next failed: #{inspect(err)}")
    end

    event({:select_incident, inc_id})
  end

  # ── BPE escalate ─────────────────────────────────────────────────────────

  def event({:fail_bpe, proc_id, req_id, inc_id}) do
    try do
      :bpe.next(proc_id, "Escalate")

      reqs = :kvs.all(~c"/itsm/reqs")
      req_rec = Enum.find(reqs, fn r ->
        :nitro.to_binary(EXO.itsm_req(r, :id)) == :nitro.to_binary(req_id)
      end)
      if req_rec do
        :kvs.append(EXO.itsm_req(req_rec, status: :under_review), ~c"/itsm/reqs")
      end
    rescue
      err -> Logger.warning("BPE Escalate failed: #{inspect(err)}")
    end

    event({:select_incident, inc_id})
  end

  # ── SLA refund ───────────────────────────────────────────────────────────

  def event({:issue_refund, client_id, inc_id}) do
    accounts = :kvs.all(~c"/exo/accounts")
    account  = Enum.find(accounts, fn a ->
      :nitro.to_binary(EXO.account(a, :client)) == :nitro.to_binary(client_id)
    end)

    if account do
      new_amount = EXO.account(account, :amount) + 1000
      :kvs.append(EXO.account(account, amount: new_amount), ~c"/exo/accounts")

      tx_id = :kvs.seq([], [])
      :kvs.append(
        EXO.transaction(id: tx_id, amount: 1000,
          description: "Компенсація за збій SLA по інциденту INC-#{:nitro.to_binary(inc_id)}"),
        ~c"/exo/transactions"
      )
      Logger.info("SLA refund +1000 UAH for client #{client_id}, incident #{inc_id}")
    end

    event({:select_incident, inc_id})
  end

  # ── legacy / fallback ─────────────────────────────────────────────────────

  def event(x) do
    Logger.info("Console event: #{inspect(x)}")
  end
end
