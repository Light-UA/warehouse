defmodule ITSM.Incident.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма реєстрації інциденту"
  def id, do: EXO.itsm_incident()

  def new(name, _incident, _) do
    :erlang.put(:priority_itsm_incident_none, :low)
    :erlang.put(:status_itsm_incident_none, :new)

    services = :kvs.all(~c"/itsm/services")
    options = Enum.with_index(services)
    |> Enum.map(fn {s, index} ->
      id = EXO.itsm_service(s, :id)
      name = EXO.itsm_service(s, :name)
      opt_name = if is_binary(id), do: String.to_atom(id), else: List.to_atom(id)
      FORM.opt(name: opt_name, checked: index == 0, title: name)
    end)

    FORM.document(
      name: :form.atom([:itsm_incident, name]),
      sections: [FORM.sec(name: ["Реєстрація інциденту: "])],
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
            :req_itsm_incident_none,
            :service_itsm_incident_none,
            :priority_itsm_incident_none,
            :status_itsm_incident_none,
            :assignee_itsm_incident_none,
            :description_itsm_incident_none
          ],
          postback: {:CreateIncident, :form.atom([:itsm_incident, name])}
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
          id: :priority,
          name: :priority,
          title: "Пріоритет:",
          type: :select,
          default: :low,
          options: [
            FORM.opt(name: :low, checked: true, title: "Низький"),
            FORM.opt(name: :medium, title: "Середній"),
            FORM.opt(name: :high, title: "Високий"),
            FORM.opt(name: :critical, title: "Критичний")
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
            FORM.opt(name: :in_progress, title: "В роботі"),
            FORM.opt(name: :escalated, title: "Ескальовано"),
            FORM.opt(name: :resolved, title: "Вирішено"),
            FORM.opt(name: :closed, title: "Закрито")
          ]
        ),
        FORM.field(
          id: :assignee,
          name: :assignee,
          type: :string,
          title: "Виконавець",
          labelClass: :label
        ),
        FORM.field(
          id: :description,
          name: :description,
          type: :string,
          title: "Опис проблеми",
          labelClass: :label
        )
      ]
    )
  end
end
