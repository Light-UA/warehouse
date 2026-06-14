defmodule WMS.ServiceOrder.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма реєстрації сервісного замовлення"
  def id, do: EXO.wms_service_order()

  def new(name, _so, _) do
    FORM.document(
      name: :form.atom([:wms_service_order, name]),
      sections: [FORM.sec(name: ["Створення Сервісного Замовлення: "])],
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
            :weapon_wms_service_order_none,
            :reason_wms_service_order_none,
            :received_by_wms_service_order_none
          ],
          postback: {:CreateSO, :form.atom([:wms_service_order, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :weapon,
          name: :weapon,
          type: :string,
          title: "ID Зброї",
          labelClass: :label
        ),
        FORM.field(
          id: :reason,
          name: :reason,
          type: :string,
          title: "Причина обслуговування",
          labelClass: :label
        ),
        FORM.field(
          id: :received_by,
          name: :received_by,
          type: :string,
          title: "Прийняв",
          labelClass: :label
        )
      ]
    )
  end
end
