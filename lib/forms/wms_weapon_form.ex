defmodule WMS.Weapon.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма реєстрації зброї"
  def id, do: EXO.wms_weapon()

  def new(name, _weapon, _) do
    FORM.document(
      name: :form.atom([:wms_weapon, name]),
      sections: [FORM.sec(name: ["Реєстрація одиниці зброї: "])],
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
            :serial_number_wms_weapon_none,
            :weapon_model_wms_weapon_none,
            :owner_wms_weapon_none,
            :storage_location_wms_weapon_none,
            :status_wms_weapon_none,
            :license_wms_weapon_none
          ],
          postback: {:SaveWeapon, :form.atom([:wms_weapon, name])}
        )
      ],
      fields: [
        FORM.field(
          id: :serial_number,
          name: :serial_number,
          type: :string,
          title: "Серійний номер",
          labelClass: :label
        ),
        FORM.field(
          id: :weapon_model,
          name: :weapon_model,
          type: :string,
          title: "Модель зброї (ID)",
          labelClass: :label
        ),
        FORM.field(
          id: :owner,
          name: :owner,
          type: :string,
          title: "Власник",
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
          id: :status,
          name: :status,
          title: "Статус:",
          type: :select,
          default: :active,
          options: [
            FORM.opt(name: :active, checked: true, title: "Активна"),
            FORM.opt(name: :maintenance, title: "На обслуговуванні"),
            FORM.opt(name: :decommissioned, title: "Списана")
          ]
        ),
        FORM.field(
          id: :license,
          name: :license,
          type: :string,
          title: "Ліцензія/дозвіл",
          labelClass: :label
        )
      ]
    )
  end
end
