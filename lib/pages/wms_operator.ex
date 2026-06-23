defmodule EXO.WMS.Operator do
  require EXO
  require NITRO

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.clear(:ctrl)
    :nitro.clear(:frms)
    # :nitro.show(:ctrl)
    :nitro.hide(:frms)

    :nitro.insert_top(:tableHead, header())

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :create_service_order,
        body: "Заявка на ремонт",
        postback: :create_service_order,
        class: [:button, :sgreen]
      )
    )

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :create_transfer_order,
        body: "Заявка на переміщення",
        postback: :create_transfer_order,
        class: [:button, :sgreen]
      )
    )

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :add_weapon,
        body: "Додати зброю",
        postback: :add_weapon,
        class: [:button, :sgreen]
      )
    )

    records = :kvs.all(~c"/wms/weapons")

    Enum.each(records, fn weapon ->
      id = EXO.wms_weapon(weapon, :id)
      :nitro.insert_bottom(:tableRow, WMS.Weapon.Row.new(id, weapon, []))
    end)
  end

  def blank?(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
    |> Kernel.==("")
  end

  def event({:SaveWeapon, data}) do
    serial_number = :nitro.q(:serial_number_wms_weapon_none)
    weapon_model = :nitro.q(:weapon_model_wms_weapon_none)
    owner = :nitro.q(:owner_wms_weapon_none)
    storage_location = :nitro.q(:storage_location_wms_weapon_none)
    status = :nitro.q(:status_wms_weapon_none)
    license = :nitro.q(:license_wms_weapon_none)

    cond do
      blank?(serial_number) ->
        WMS.UI.show_error(:operator_error, "Помилка: серійний номер обов’язковий")

      blank?(weapon_model) ->
        WMS.UI.show_error(:operator_error, "Помилка: модель зброї обов’язкова")

      blank?(owner) ->
        WMS.UI.show_error(:operator_error, "Помилка: власник обов’язковий")

      blank?(storage_location) ->
        WMS.UI.show_error(:operator_error, "Помилка: локація зберігання обов’язкова")

      blank?(status) ->
        WMS.UI.show_error(:operator_error, "Помилка: статус обов’язковий")

      blank?(license) ->
        WMS.UI.show_error(:operator_error, "Помилка: ліцензія/дозвіл обов’язкова")

      true ->
        EXO.WMS.Weapons.event({:SaveWeapon, data})
        event(:init)
    end
  end

  def event({:Close, _data}) do
    :nitro.clear(:frms)
    :nitro.hide(:frms)
  end

  def event(:add_weapon) do
    :nitro.clear(:frms)

    :nitro.insert_bottom(
      :frms,
      NITRO.panel(
        id: :operator_error,
        body: []
      )
    )

    mod = WMS.Weapon.Form
    form = mod.new(:none, mod.id(), [])

    :nitro.insert_bottom(:frms, :form.new(form, mod.id(), []))
    :nitro.show(:frms)
  end

  def event(:create_service_order) do
    :nitro.redirect("repair.htm")
  end

  def event(:create_transfer_order) do
    :nitro.redirect("logistics.htm")
  end

  def event(_), do: :ok

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, body: "ID"),
        NITRO.panel(class: :column20, body: "Серійний номер"),
        NITRO.panel(class: :column20, body: "Модель"),
        NITRO.panel(class: :column20, body: "Власник"),
        NITRO.panel(class: :column10, body: "Ліцензія"),
        NITRO.panel(class: :column20, body: "Локація"),
        NITRO.panel(class: :column20, body: "Статус")
      ]
    )
  end
end
