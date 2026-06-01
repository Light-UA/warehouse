defmodule ITSM.Service.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма створення ІТ-сервісу"
  def id, do: EXO.itsm_service()

  def new(name, _service, _) do
    :erlang.put(:status_itsm_service_none, :active)

    FORM.document(
      name: :form.atom([:itsm_service, name]),
      sections: [FORM.sec(name: ["Створення ІТ-сервісу: "])],
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
            :name_itsm_service_none,
            :description_itsm_service_none,
            :owner_itsm_service_none,
            :status_itsm_service_none
          ],
          postback: {:CreateService, :form.atom([:itsm_service, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :name,
          name: :name,
          type: :string,
          title: "Назва сервісу",
          labelClass: :label
        ),
        FORM.field(
          id: :description,
          name: :description,
          type: :string,
          title: "Опис сервісу",
          labelClass: :label
        ),
        FORM.field(
          id: :owner,
          name: :owner,
          type: :string,
          title: "Власник сервісу",
          labelClass: :label
        ),
        FORM.field(
          id: :status,
          name: :status,
          title: "Статус:",
          type: :select,
          default: :active,
          postback: {:TypeStatus, :form.atom([:itsm_service, name])},
          options: [
            FORM.opt(name: :active, checked: true, title: "Активний"),
            FORM.opt(name: :draft, title: "Чернетка"),
            FORM.opt(name: :inactive, title: "Неактивний")
          ]
        )
      ]
    )
  end
end
