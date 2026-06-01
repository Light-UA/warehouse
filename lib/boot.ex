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

    # Active outage (incident) on Internet (1 item)
    if :kvs.all(~c"/itsm/incidents") == [] do
      sample_incidents = [
        EXO.itsm_incident(
          id: :kvs.seq([], []),
          req: "INC-001",
          service: "internet",
          priority: :high,
          status: :in_progress,
          assignee: "Черговий інженер",
          description: "Спостерігається падіння швидкості та обриви зв'язку через аварію на лінії."
        )
      ]
      :lists.map(fn x -> :kvs.append(x, ~c"/itsm/incidents") end, sample_incidents)
    end

    # Support ticket for client МВС (phone 3) in Work state (BPE)
    if :kvs.all(~c"/itsm/reqs") == [] do
      req_id = :kvs.seq([], [])
      date = :calendar.now_to_datetime(:erlang.timestamp())
      req = EXO.itsm_req(
        id: req_id,
        initiator: "3",
        service: "internet",
        title: "Проблеми зі зв'язком в офісі",
        description: "Не працює VPN-з'єднання з центральним сервером",
        status: :in_progress,
        created_at: date,
        closed_at: []
      )
      :kvs.append(req, ~c"/itsm/reqs")

      # Start BPE Incident workflow and progress it to Work state
      case :bpe.start(BPE.Incident.def(), [req]) do
        {:ok, proc_id} ->
          :bpe.next(proc_id) # New -> Triaje
          :bpe.next(proc_id) # Triaje -> Work
          Logger.info("Seeded BPE incident workflow #{proc_id} in Work state for ticket #{req_id}")
        err ->
          Logger.warning("Failed to start BPE workflow in boot: #{inspect(err)}")
      end

      # Seed Change request (1 item)
      if :kvs.all(~c"/itsm/changes") == [] do
        chg_id = :kvs.seq([], [])
        chg = EXO.itsm_change(
          id: chg_id,
          req: req_id,
          service: "internet",
          title: "Модернізація магістрального кабелю",
          description: "Заміна пошкодженої ділянки оптоволокна",
          risk_level: :medium,
          impact: :medium,
          status: :in_progress,
          change_manager: "Адміністратор",
          backout_plan: "Переключення на резервний мідний кабель"
        )
        :kvs.append(chg, ~c"/itsm/changes")

        # Start BPE Change workflow and progress it to Analyze state
        case :bpe.start(BPE.Change.def(), [chg]) do
          {:ok, chg_proc_id} ->
            :bpe.next(chg_proc_id) # New -> Analyze
            Logger.info("Seeded BPE change workflow #{chg_proc_id} in Analyze state for change #{chg_id}")
          err ->
            Logger.warning("Failed to start BPE Change workflow in boot: #{inspect(err)}")
        end
      end
    end
    :ok
  end
end
