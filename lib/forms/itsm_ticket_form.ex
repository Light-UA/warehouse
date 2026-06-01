defmodule ITSM.Ticket.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма створення звернення (Ticket)"
  def id, do: EXO.itsm_req()

  def new(name, _req, _) do
    :erlang.put(:priority_itsm_req_none, :low)

    FORM.document(
      name: :form.atom([:itsm_req, name]),
      sections: [FORM.sec(name: ["Створити нове звернення: "])],
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
          title: "Надіслати",
          class: [:button, :sgreen],
          sources: [
            :service_itsm_req_none,
            :title_itsm_req_none,
            :description_itsm_req_none,
            :priority_itsm_req_none
          ],
          postback: {:CreateTicket, :form.atom([:itsm_req, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :service,
          name: :service,
          title: "Послуга:",
          type: :select,
          default: :internet,
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
          id: :title,
          name: :title,
          type: :string,
          title: "Тема звернення:",
          labelClass: :label
        ),
        FORM.field(
          id: :description,
          name: :description,
          type: :string,
          title: "Детальний опис:",
          labelClass: :label
        ),
        FORM.field(
          id: :priority,
          name: :priority,
          title: "Терміновість (пріоритет):",
          type: :select,
          default: :low,
          options: [
            FORM.opt(name: :low, checked: true, title: "Низька"),
            FORM.opt(name: :medium, title: "Середня"),
            FORM.opt(name: :high, title: "Висока")
          ]
        )
      ]
    )
  end
end
