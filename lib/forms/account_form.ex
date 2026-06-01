defmodule Account.Form do
  require EXO
  require NITRO
  require FORM
  require BPE
  def doc(), do: "Форма вводу облікового запису користувача системи"
  def id, do: EXO.account()

  def new(name, _program, _) do
    :erlang.put(:type_account_none, :type)

    programs = :kvs.all(~c"/exo/tariffs")
    options = Enum.with_index(programs)
    |> Enum.map(fn {x, index} ->
      type = EXO.program(x, :type)
      name = EXO.program(x, :name)
      FORM.opt(name: EXO.program(x, :id), checked: index == 0, title: "#{type}-#{name}")
    end)

    FORM.document(
      name: :form.atom([:account, name]),
      sections: [FORM.sec(name: ["Створення рахунку: "])],
      buttons: [
        FORM.but(
          id: :decline,
          name: :decline,
          title: "Відміна",
          class: [:cancel],
          postback: {:Close, []}
        ),
        FORM.but(
          id: :proceed,
          name: :proceed,
          title: "Створити",
          class: [:button, :sgreen],
          sources: [
            :name_account_none,
            :edrpou_account_none,
            :type_account_none,
            :program_account_none,
            :date_account_none
          ],
          postback: {:CreateAccount, :form.atom([:account, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :name,
          name: :name,
          type: :string,
          title: "Ім'я клієнта",
          labelClass: :label
        ),
        FORM.field(
          id: :edrpou,
          name: :edrpou,
          type: :string,
          title: "ЄДРПОУ",
          labelClass: :label
        ),
        FORM.field(
          id: :type,
          name: :type,
          title: "Тип:",
          type: :select,
          default: :internet,
          postback: {:TypeAccount, :form.atom([:account, name])},
          options: [
            FORM.opt(name: :internet, checked: true, title: "Інтернет"),
            FORM.opt(name: :electricity, title: "Електропостачання"),
            FORM.opt(name: :bankruptcy, title: "ІДС \"Банкрутство\""),
            FORM.opt(name: :court_decisions_images, title: "Сервіс систематизації образів судових рішень"),
            FORM.opt(name: :court_cases_scheduled, title: "Сервіс систематизації призначених справ"),
            FORM.opt(name: :court_decisions_hyperlinks, title: "Сервіс гіперпосилань у судових рішеннях")
          ]
        ),
        FORM.field(
          id: :program,
          name: :program,
          title: "Тарифна модель:",
          type: :select,
          default: :internet,
          postback: {:ProgramAccount, :form.atom([:account, name])},
          options: options
        ),
        FORM.field(
          id: :date,
          name: :date,
          type: :calendar,
          title: "Дата",
          labelClass: :label
        )
      ]
    )
  end
end
