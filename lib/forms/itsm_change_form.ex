defmodule ITSM.Change.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма створення запиту на зміну (RFC)"
  def id, do: EXO.itsm_change()

  def new(name, _change, _) do
    :erlang.put(:risk_level_itsm_change_none, :low)
    :erlang.put(:impact_itsm_change_none, :low)
    :erlang.put(:status_itsm_change_none, :new)

    services = :kvs.all(~c"/itsm/services")
    options = Enum.with_index(services)
    |> Enum.map(fn {s, index} ->
      id = EXO.itsm_service(s, :id)
      name = EXO.itsm_service(s, :name)
      opt_name = if is_binary(id), do: String.to_atom(id), else: List.to_atom(id)
      FORM.opt(name: opt_name, checked: index == 0, title: name)
    end)

    FORM.document(
      name: :form.atom([:itsm_change, name]),
      sections: [FORM.sec(name: ["Створення запиту на зміну (RFC): "])],
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
            :req_itsm_change_none,
            :service_itsm_change_none,
            :title_itsm_change_none,
            :description_itsm_change_none,
            :risk_level_itsm_change_none,
            :impact_itsm_change_none,
            :status_itsm_change_none,
            :change_manager_itsm_change_none,
            :backout_plan_itsm_change_none
          ],
          postback: {:CreateChange, :form.atom([:itsm_change, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :req,
          name: :req,
          type: :string,
          title: "ID Звернення (якщо є)",
          labelClass: :label
        ),
        FORM.field(
          id: :service,
          name: :service,
          title: "Сервіс:",
          type: :select,
          default: :internet,
          options: options
        ),
        FORM.field(
          id: :title,
          name: :title,
          type: :string,
          title: "Заголовок зміни",
          labelClass: :label
        ),
        FORM.field(
          id: :description,
          name: :description,
          type: :string,
          title: "Опис зміни",
          labelClass: :label
        ),
        FORM.field(
          id: :risk_level,
          name: :risk_level,
          title: "Рівень ризику:",
          type: :select,
          default: :low,
          options: [
            FORM.opt(name: :low, checked: true, title: "Низький"),
            FORM.opt(name: :medium, title: "Середній"),
            FORM.opt(name: :high, title: "Високий")
          ]
        ),
        FORM.field(
          id: :impact,
          name: :impact,
          title: "Рівень впливу:",
          type: :select,
          default: :low,
          options: [
            FORM.opt(name: :low, checked: true, title: "Низький"),
            FORM.opt(name: :medium, title: "Середній"),
            FORM.opt(name: :high, title: "Високий")
          ]
        ),
        FORM.field(
          id: :status,
          name: :status,
          title: "Статус:",
          type: :select,
          default: :new,
          options: [
            FORM.opt(name: :new, checked: true, title: "Новий"),
            FORM.opt(name: :accepted, title: "Прийнято"),
            FORM.opt(name: :under_analysis, title: "Аналіз"),
            FORM.opt(name: :planning, title: "Планування"),
            FORM.opt(name: :executing, title: "Виконання"),
            FORM.opt(name: :closed, title: "Закрито")
          ]
        ),
        FORM.field(
          id: :change_manager,
          name: :change_manager,
          type: :string,
          title: "Менеджер зміни",
          labelClass: :label
        ),
        FORM.field(
          id: :backout_plan,
          name: :backout_plan,
          type: :string,
          title: "План відкату",
          labelClass: :label
        )
      ]
    )
  end
end
