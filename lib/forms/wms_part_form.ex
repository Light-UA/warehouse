defmodule WMS.Part.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма реєстрації деталі/запчастини"
  def id, do: EXO.wms_part()

  def new(name, _part, _) do
    FORM.document(
      name: :form.atom([:wms_part, name]),
      sections: [FORM.sec(name: ["Реєстрація деталі/запчастини: "])],
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
            :serial_number_wms_part_none,
            :part_type_wms_part_none,
            :part_status_wms_part_none,
            :installed_in_weapon_wms_part_none,
            :storage_location_wms_part_none,
            :manufacturer_wms_part_none
          ],
          postback: {:SavePart, :form.atom([:wms_part, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :serial_number,
          name: :serial_number,
          type: :string,
          title: "Серійний номер деталі",
          labelClass: :label
        ),
        FORM.field(
          id: :part_type,
          name: :part_type,
          type: :string,
          title: "Тип деталі",
          labelClass: :label
        ),
        FORM.field(
          id: :part_status,
          name: :part_status,
          title: "Статус деталі:",
          type: :select,
          default: :spare,
          options: [
            FORM.opt(name: :spare, checked: true, title: "Запасна"),
            FORM.opt(name: :installed, title: "Встановлена"),
            FORM.opt(name: :removed, title: "Знята"),
            FORM.opt(name: :broken, title: "Зламана"),
            FORM.opt(name: :decommissioned, title: "Списана")
          ]
        ),
        FORM.field(
          id: :installed_in_weapon,
          name: :installed_in_weapon,
          type: :string,
          title: "ID зброї",
          labelClass: :label
        ),
        FORM.field(
          id: :storage_location,
          name: :storage_location,
          type: :string,
          title: "Локація зберігання",
          labelClass: :label
        ),
        FORM.field(
          id: :manufacturer,
          name: :manufacturer,
          type: :string,
          title: "Виробник",
          labelClass: :label
        )
      ]
    )
  end
end
