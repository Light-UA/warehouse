defmodule WMS.ServiceEvent.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма реєстрації сервісної події"
  def id, do: EXO.wms_service_event()

  def new(name, _event, _) do
    FORM.document(
      name: :form.atom([:wms_service_event, name]),
      sections: [FORM.sec(name: ["Реєстрація сервісної події:"])],
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
          title: "Зберегти",
          class: [:button, :sgreen],
          sources: [
            :service_order_wms_service_event_none,
            :weapon_wms_service_event_none,
            :event_type_wms_service_event_none,
            :actor_wms_service_event_none,
            :event_status_wms_service_event_none,
            :condition_wms_service_event_none,
            :required_action_wms_service_event_none,
            :result_wms_service_event_none,
            :old_part_wms_service_event_none,
            :new_part_wms_service_event_none
          ],
          postback: {:SaveServiceEvent, :form.atom([:wms_service_event, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :service_order,
          name: :service_order,
          type: :string,
          title: "Сервісний наряд",
          labelClass: :label
        ),
        FORM.field(
          id: :weapon,
          name: :weapon,
          type: :string,
          title: "ID зброї",
          labelClass: :label
        ),
        FORM.field(
          id: :event_type,
          name: :event_type,
          type: :string,
          title: "Тип події",
          labelClass: :label
        ),
        FORM.field(
          id: :actor,
          name: :actor,
          type: :string,
          title: "Виконавець",
          labelClass: :label
        ),
        FORM.field(
          id: :event_status,
          name: :event_status,
          title: "Статус події",
          type: :select,
          default: :completed,
          options: [
            FORM.opt(name: :planned, title: "Запланована"),
            FORM.opt(name: :in_progress, title: "В процесі"),
            FORM.opt(name: :completed, checked: true, title: "Завершена"),
            FORM.opt(name: :cancelled, title: "Скасована")
          ]
        ),
        FORM.field(
          id: :required_action,
          name: :required_action,
          type: :string,
          title: "Необхідна дія",
          labelClass: :label
        ),
        FORM.field(
          id: :result,
          name: :result,
          type: :string,
          title: "Результат",
          labelClass: :label
        ),
        FORM.field(
          id: :condition,
          name: :condition,
          type: :string,
          title: "Стан зброї",
          labelClass: :label
        ),
        FORM.field(
          id: :old_part,
          name: :old_part,
          type: :string,
          title: "Стара деталь (ID)",
          labelClass: :label
        ),
        FORM.field(
          id: :new_part,
          name: :new_part,
          type: :string,
          title: "Нова деталь (ID)",
          labelClass: :label
        )
      ]
    )
  end
end
