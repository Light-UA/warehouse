defmodule EXO.Boot do
  require EXO
  require Logger

  def clients() do
    case :kvs.all(~c"/exo/clients") do
      [] ->
        date = :calendar.now_to_datetime(:erlang.timestamp())
        ids = :lists.map(fn _ -> :timer.sleep(1) ; :kvs.seq([],[]) end, :lists.seq(1,6))
        sample = [
          EXO.client(
            id: :lists.nth(1,ids),
            names: "Максим",
            phone: "1",
            surnames: "Сохацький",
            type: :admin,
            status: :online,
            date: date
          ),
          EXO.client(
            id: :lists.nth(2,ids),
            names: "Антон",
            phone: "2",
            surnames: "Волошко",
            type: :admin,
            status: :online,
            date: date
          ),
          EXO.client(
            id: :lists.nth(3,ids),
            names: "МВС",
            phone: "3",
            surnames: "",
            type: :consumer,
            status: :online,
            date: date
          ),
          EXO.client(
            id: :lists.nth(4,ids),
            names: "ГСЦ",
            phone: "4",
            surnames: "",
            type: :consumer,
            status: :online,
            date: date
          ),
          EXO.client(
            id: :lists.nth(5,ids),
            names: "ЦІТ",
            phone: "5",
            surnames: "",
            type: :consumer,
            status: :online,
            date: date
          ),
          EXO.client(
            id: :lists.nth(6,ids),
            names: "ДНДІ",
            phone: "6",
            surnames: "",
            type: :consumer,
            status: :online,
            date: date
          )
        ]

        :lists.map(fn x -> :kvs.append(x, ~c"/exo/clients") end, sample)
      _ ->
        :ok
    end
  end

  def programs() do
    current_programs = :kvs.all(~c"/exo/tariffs")
    has_gas_or_oil = Enum.any?(current_programs, fn p -> EXO.program(p, :type) in [:gas, :oil] end)
    if current_programs == [] or has_gas_or_oil do
      if current_programs != [] do
        Enum.each(current_programs, fn p -> :kvs.delete(~c"/exo/tariffs", EXO.program(p, :id)) end)
        :kvs.delete(:writer, ~c"/exo/tariffs")
      end

      date = :calendar.now_to_datetime(:erlang.timestamp())
      ids = :lists.map(fn _ -> :timer.sleep(1) ; :kvs.seq([],[]) end, :lists.seq(1,12))

      sample = [
          EXO.program(id: :lists.nth(1, ids), name: "БАЗОВИЙ", type: :internet, date: date),
          EXO.program(id: :lists.nth(2, ids), name: "СТАНДАРТ", type: :internet, date: date),
          EXO.program(id: :lists.nth(3, ids), name: "БАЗОВИЙ", type: :electricity, date: date),
          EXO.program(id: :lists.nth(4, ids), name: "СТАНДАРТ", type: :electricity, date: date),
          EXO.program(id: :lists.nth(5, ids), name: "БАЗОВИЙ", type: :bankruptcy, date: date),
          EXO.program(id: :lists.nth(6, ids), name: "СТАНДАРТ", type: :bankruptcy, date: date),
          EXO.program(id: :lists.nth(7, ids), name: "БАЗОВИЙ", type: :court_decisions_images, date: date),
          EXO.program(id: :lists.nth(8, ids), name: "СТАНДАРТ", type: :court_decisions_images, date: date),
          EXO.program(id: :lists.nth(9, ids), name: "БАЗОВИЙ", type: :court_cases_scheduled, date: date),
          EXO.program(id: :lists.nth(10, ids), name: "СТАНДАРТ", type: :court_cases_scheduled, date: date),
          EXO.program(id: :lists.nth(11, ids), name: "БАЗОВИЙ", type: :court_decisions_hyperlinks, date: date),
          EXO.program(id: :lists.nth(12, ids), name: "СТАНДАРТ", type: :court_decisions_hyperlinks, date: date)
        ]

        :lists.map(fn x -> :kvs.append(x, ~c"/exo/tariffs") end, sample)
        :ok
      else
        :ok
      end
  end

  def accounts() do
    case :kvs.all(~c"/exo/accounts") do
      [] ->
        date = :calendar.now_to_datetime(:erlang.timestamp())
        clients = :kvs.all(~c"/exo/clients")
        programs = :kvs.all(~c"/exo/tariffs")

        internet_prog = Enum.find(programs, fn p -> EXO.program(p, :type) == :internet end)

        Enum.each(clients, fn client ->
          phone = EXO.client(client, :phone)
          if phone in ["3", "5", "6"] do
            client_id = EXO.client(client, :id)
            acc_id = :kvs.seq([], [])
            acc = EXO.account(
              id: acc_id,
              client: client_id,
              type: :internet,
              iban: "UA" <> to_string(:rand.uniform(10_000_000_000_000_000_000_000)),
              program: if(internet_prog, do: EXO.program(internet_prog, :id), else: []),
              amount: 5000,
              state: :open,
              date: date
            )
            :kvs.append(acc, ~c"/exo/accounts")
            Logger.info("Seeded account for client phone #{phone} (id: #{client_id}) with balance 5000 UAH")
          end
        end)
      _ ->
        :ok
    end
  end

  def itsm() do
    current_services = :kvs.all(~c"/itsm/services")
    has_bankruptcy = Enum.any?(current_services, fn s -> EXO.itsm_service(s, :id) == "bankruptcy" end)
    has_gas_or_oil = Enum.any?(current_services, fn s -> EXO.itsm_service(s, :id) in ["gas", "oil"] end)
    if current_services == [] or not has_bankruptcy or has_gas_or_oil do
      if current_services != [] do
        Enum.each(current_services, fn s -> :kvs.delete(~c"/itsm/services", EXO.itsm_service(s, :id)) end)
        :kvs.delete(:writer, ~c"/itsm/services")
      end

      sample_services = [
        EXO.itsm_service(id: "internet", name: "Інтернет", description: "Широкосмуговий доступ до мережі Інтернет", owner: "ІСС Мережі", status: :active),
        EXO.itsm_service(id: "electricity", name: "Електропостачання", description: "Постачання електроенергії", owner: "Київські Енергомережі", status: :active),
        EXO.itsm_service(
          id: "bankruptcy",
          name: "Інформаційно-довідкова система \"Банкрутство\"",
          description: "Послуги з надання інформації про підприємства щодо яких порушено справу про банкрутство та стан проходження цих справ.",
          owner: "ДП «Інформаційні судові системи»",
          status: :active
        ),
        EXO.itsm_service(
          id: "court_decisions_images",
          name: "Сервіс систематизації образів судових рішень",
          description: "Послуга з систематизації за обраними критеріями образів автоматично створених електронних копій судових рішень або інших документів, які містяться в Єдиному державному реєстрі судових рішень.",
          owner: "ДП «Інформаційні судові системи»",
          status: :active
        ),
        EXO.itsm_service(
          id: "court_cases_scheduled",
          name: "Сервіс систематизації переліку судових справ, призначених до розгляду",
          description: "Послуга з отримання переліку судових справ, призначених до розгляду.",
          owner: "ДП «Інформаційні судові системи»",
          status: :active
        ),
        EXO.itsm_service(
          id: "court_decisions_hyperlinks",
          name: "Сервіс зі створення гіпертекстових посилань в текстах судових рішень",
          description: "Мета послуги - підвищення інформативності документів, які містяться в Єдиному державному реєстрі судових рішень, за рахунок створення гіпертекстових посилань на первинні нормативні документи, згадувані в текстах рішень та розміщені в інформаційно-правових системах користувача.",
          owner: "ДП «Інформаційні судові системи»",
          status: :active
        )
      ]
      :lists.map(fn x -> :kvs.append(x, ~c"/itsm/services") end, sample_services)
    end

    if :kvs.all(~c"/itsm/slas") == [] do
      ids = :lists.map(fn _ -> :timer.sleep(1) ; :kvs.seq([],[]) end, :lists.seq(1,2))
      sample_slas = [
        EXO.itsm_sla(id: :lists.nth(1, ids), service: "internet", priority: :low, response_time: 120, resolution_time: 480, status: :active),
        EXO.itsm_sla(id: :lists.nth(2, ids), service: "electricity", priority: :critical, response_time: 15, resolution_time: 60, status: :active)
      ]
      :lists.map(fn x -> :kvs.append(x, ~c"/itsm/slas") end, sample_slas)
    end

    if :kvs.all(~c"/itsm/cis") == [] do
      ids = :lists.map(fn _ -> :timer.sleep(1) ; :kvs.seq([],[]) end, :lists.seq(1,2))
      sample_cis = [
        EXO.itsm_ci(id: :lists.nth(1, ids), name: "Магістральний оптоволоконний кабель", type: :hardware, status: :active, dependencies: [], serial_number: "FIB-MAG-01", owner: "ІСС Мережі"),
        EXO.itsm_ci(id: :lists.nth(2, ids), name: "Трансформаторна підстанція ТП-402", type: :hardware, status: :active, dependencies: [], serial_number: "SUB-EL-402", owner: "Київські Енергомережі")
      ]
      :lists.map(fn x -> :kvs.append(x, ~c"/itsm/cis") end, sample_cis)
    end

    # ── Step 1: ensure req exists and get its id ─────────────────────────────
    req_id =
      case :kvs.all(~c"/itsm/reqs") do
        [] ->
          :timer.sleep(1)
          rid = :kvs.seq([], [])
          date = :calendar.now_to_datetime(:erlang.timestamp())
          req = EXO.itsm_req(
            id: rid,
            initiator: "3",
            service: "internet",
            title: "Проблеми зі зв'язком в офісі МВС",
            description: "Не працює VPN-з'єднання з центральним сервером. Зачіпає 40 робочих місць.",
            status: :in_progress,
            created_at: date,
            closed_at: []
          )
          :kvs.append(req, ~c"/itsm/reqs")

          # BPE workflow for this req
          case :bpe.start(BPE.Incident.def(), [req]) do
            {:ok, proc_id} ->
              :bpe.next(proc_id) # New -> Triaje
              :bpe.next(proc_id) # Triaje -> Work
              Logger.info("Seeded BPE incident workflow #{proc_id} in Work state for req #{rid}")
            err ->
              Logger.warning("Failed to start BPE workflow in boot: #{inspect(err)}")
          end

          rid

        [existing | _] ->
          EXO.itsm_req(existing, :id)
      end

    # ── Step 2: seed 6 incidents; first one links to req ─────────────────────
    # Re-seed whenever count < 6 (wipe old first to avoid list corruption)
    current_incidents = :kvs.all(~c"/itsm/incidents")
    if length(current_incidents) < 6 do
      Enum.each(current_incidents, fn i ->
        :kvs.delete(~c"/itsm/incidents", EXO.itsm_incident(i, :id))
      end)
      if current_incidents != [] do
        :kvs.delete(:writer, ~c"/itsm/incidents")
      end

      inc_ids = :lists.map(fn _ -> :timer.sleep(1); :kvs.seq([], []) end, :lists.seq(1, 6))

      # NOTE: req_id goes directly into incident #1 — no post-hoc patching
      sample_incidents = [
        EXO.itsm_incident(
          id: :lists.nth(1, inc_ids),
          req: req_id,
          service: "internet",
          priority: :high,
          status: :in_progress,
          assignee: "Іваненко О.П.",
          description: "Падіння швидкості та обриви зв'язку через аварію на магістральній лінії.",
          resolution: "",
          slm_deadline: []
        ),
        EXO.itsm_incident(
          id: :lists.nth(2, inc_ids),
          req: [],
          service: "electricity",
          priority: :critical,
          status: :new,
          assignee: "Петренко В.М.",
          description: "Повне відключення живлення у серверній кімнаті корпусу А.",
          resolution: "",
          slm_deadline: []
        ),
        EXO.itsm_incident(
          id: :lists.nth(3, inc_ids),
          req: [],
          service: "bankruptcy",
          priority: :medium,
          status: :accepted,
          assignee: "Коваленко С.Г.",
          description: "API повертає помилку 500 при запиті переліку справ за датою.",
          resolution: "",
          slm_deadline: []
        ),
        EXO.itsm_incident(
          id: :lists.nth(4, inc_ids),
          req: [],
          service: "court_decisions_images",
          priority: :low,
          status: :resolved,
          assignee: "Бойко Д.Р.",
          description: "Затримка у формуванні образів рішень понад 2 хвилини.",
          resolution: "Збільшено потужність черги обробки зображень. Затримки усунуто.",
          slm_deadline: []
        ),
        EXO.itsm_incident(
          id: :lists.nth(5, inc_ids),
          req: [],
          service: "court_cases_scheduled",
          priority: :medium,
          status: :escalated,
          assignee: "Мороз Л.В.",
          description: "Відсутні дані про призначені справи за 01.06.2026 у відповіді API.",
          resolution: "",
          slm_deadline: []
        ),
        EXO.itsm_incident(
          id: :lists.nth(6, inc_ids),
          req: [],
          service: "court_decisions_hyperlinks",
          priority: :high,
          status: :in_progress,
          assignee: "Лисенко А.Ю.",
          description: "Гіперпосилання в рішеннях ЄДРСР ведуть на застарілі URL нормативних актів.",
          resolution: "",
          slm_deadline: []
        )
      ]
      :lists.map(fn x -> :kvs.append(x, ~c"/itsm/incidents") end, sample_incidents)
      Logger.info("Seeded #{length(sample_incidents)} incidents into /itsm/incidents")
    end

    # ── Step 3: seed change request ───────────────────────────────────────────
    if :kvs.all(~c"/itsm/changes") == [] do
      :timer.sleep(1)
      chg_id = :kvs.seq([], [])
      chg = EXO.itsm_change(
        id: chg_id,
        req: req_id,
        service: "internet",
        title: "Модернізація магістрального кабелю",
        description: "Заміна пошкодженої ділянки оптоволокна для відновлення стабільного з'єднання.",
        risk_level: :medium,
        impact: :medium,
        status: :in_progress,
        change_manager: "Адміністратор",
        backout_plan: "Переключення на резервний мідний кабель"
      )
      :kvs.append(chg, ~c"/itsm/changes")

      case :bpe.start(BPE.Change.def(), [chg]) do
        {:ok, chg_proc_id} ->
          :bpe.next(chg_proc_id) # New -> Analyze
          Logger.info("Seeded BPE change workflow #{chg_proc_id} in Analyze state for change #{chg_id}")
        err ->
          Logger.warning("Failed to start BPE Change workflow in boot: #{inspect(err)}")
      end
    end

    :ok
  end
end
