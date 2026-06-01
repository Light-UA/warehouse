defmodule EXO.Service do
  require EXO
  require BPE
  require NITRO

  def showTariffs(type) do
    :nitro.clear(:tariffs)
    :nitro.insert_bottom(:tariffs, EXO.Tariffs.header())

    :lists.map(
      fn x ->
        case :nitro.to_binary(EXO.program(x, :type)) do
          t when t == type ->
            :nitro.insert_bottom(
              :tariffs,
              Program.Row.new(:form.atom([:row, EXO.program(x, :id)]), x, [])
            )

          _ ->
            :skip
        end
      end,
      :kvs.all(~c"/exo/tariffs")
    )
  end

  def event(:init) do
    :nitro.clear(:serviceTypes)
    :nitro.insert_top(:tariffs, EXO.Tariffs.header())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)
    mod = Account.Form
    form = :form.new(mod.new(mod, mod.id(), []), mod.id(), [])
    :nitro.insert_bottom(:frms, form)

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(id: :creator, body: "Новий", postback: :create, class: [:button, :sgreen])
    )

    :nitro.hide(:frms)

    :nitro.insert_bottom(:serviceTypes, serviceHeader())

    :nitro.insert_bottom(
      :serviceTypes,
      NITRO.panel(
        class: :td,
        style: "height: 25px;",
        body: NITRO.link(id: "bankruptcy", postback: {:showTariffs, "bankruptcy"}, body: "ІДС \"Банкрутство\"")
      )
    )

    :nitro.insert_bottom(
      :serviceTypes,
      NITRO.panel(
        class: :td,
        style: "height: 25px;",
        body: NITRO.link(id: "court_decisions_images", postback: {:showTariffs, "court_decisions_images"}, body: "Систематизація образів рішень")
      )
    )

    :nitro.insert_bottom(
      :serviceTypes,
      NITRO.panel(
        class: :td,
        style: "height: 25px;",
        body: NITRO.link(id: "court_cases_scheduled", postback: {:showTariffs, "court_cases_scheduled"}, body: "Систематизація призначених справ")
      )
    )

    :nitro.insert_bottom(
      :serviceTypes,
      NITRO.panel(
        class: :td,
        style: "height: 25px;",
        body: NITRO.link(id: "court_decisions_hyperlinks", postback: {:showTariffs, "court_decisions_hyperlinks"}, body: "Гіперпосилання в рішеннях")
      )
    )

    :nitro.insert_bottom(
      :serviceTypes,
      NITRO.panel(
        class: :td,
        style: "height: 25px;",
        body:
          NITRO.link(
            id: "electricity",
            postback: {:showTariffs, "electricity"},
            body: "Електрика"
          )
      )
    )

    :nitro.insert_bottom(
      :serviceTypes,
      NITRO.panel(
        class: :td,
        style: "height: 25px;",
        body: NITRO.link(id: "internet", postback: {:showTariffs, "internet"}, body: "Інтернет")
      )
    )

    showTariffs("internet")
  end

  def event({:showTariffs, e}) do
    showTariffs(e)
  end

  def event(:create) do
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
  end

  def event({:CreateTariff, _}) do
    date = :date_program_none |> :nitro.q()
    name = :name_program_none |> :nitro.q()
    formula = :formula_program_none |> :nitro.q()
    id = :kvs.seq([], [])
    tariff = EXO.program(date: date, id: id, formula: formula, name: name)
    nitro = :form.new(Program.Row.new(:form.atom([:row, name]), tariff, []), tariff, [])
    :kvs.append(tariff, ~c"/exo/tariffs")
    :nitro.insert_top(:tableRow, nitro)
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event({:Close, []}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(_), do: :ok

  def serviceHeader() do
    NITRO.panel(
      id: :serviceTypeHeader,
      class: :th,
      body: [NITRO.panel(class: :column20, body: "Тип")]
    )
  end
end
