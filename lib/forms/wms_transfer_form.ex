defmodule WMS.TransferOrder.Form do
  require EXO
  require NITRO
  require FORM

  def doc(), do: "Форма створення наряду на переміщення"
  def id, do: EXO.wms_transfer()

  def new(name, _to, _) do
    FORM.document(
      name: :form.atom([:wms_transfer, name]),
      sections: [FORM.sec(name: ["Створення наряду на переміщення: "])],
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
            :weapon_wms_transfer_none,
            :from_storage_wms_transfer_none,
            :to_storage_wms_transfer_none
          ],
          postback: {:CreateTO, :form.atom([:wms_transfer, name])}
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
          id: :from_storage,
          name: :from_storage,
          type: :string,
          title: "Початковий склад",
          labelClass: :label
        ),
        FORM.field(
          id: :to_storage,
          name: :to_storage,
          type: :string,
          title: "Кінцевий склад",
          labelClass: :label
        )
      ]
    )
  end
end
