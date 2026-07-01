defmodule EXO.WMS.Operator do
  require EXO
  require NITRO

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.clear(:frms)
    :nitro.hide(:frms)

    :nitro.insert_top(:tableHead, header())

    render_toolbar(:list)

    records = :kvs.all(~c"/wms/weapons")
    render_weapons(records)
  end

  def event(:clear_weapon_search) do
    render_toolbar(:list)

    records = :kvs.all(~c"/wms/weapons")
    render_weapons(records)
  end

  def event(:search_weapon) do
    query =
      :weapon_search
      |> :nitro.q()
      |> WMS.WeaponRules.clean()
      |> String.downcase()

    status_filter =
      :weapon_status_filter
      |> :nitro.q()
      |> WMS.WeaponRules.clean()

    records =
      :kvs.all(~c"/wms/weapons")
      |> Enum.filter(fn weapon ->
        fields = [
          EXO.wms_weapon(weapon, :id),
          EXO.wms_weapon(weapon, :serial_number),
          EXO.wms_weapon(weapon, :weapon_model),
          EXO.wms_weapon(weapon, :owner)
        ]

        matches_text =
          query == "" or
            Enum.any?(fields, fn value ->
              value
              |> :nitro.to_binary()
              |> String.downcase()
              |> String.contains?(query)
            end)

        weapon_status =
          weapon
          |> EXO.wms_weapon(:status)
          |> WMS.WeaponRules.clean()

        matches_status =
          status_filter == "" or
            status_filter == "all" or
            weapon_status == status_filter

        matches_text and matches_status
      end)

    cond do
      records == [] ->
        :nitro.clear(:tableRow)

      true ->
        render_weapons(records)
    end
  end

  def blank?(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
    |> Kernel.==("")
  end

  def clean(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
  end

  def event({:SaveWeapon, data}) do
    serial_number = :nitro.q(:serial_number_wms_weapon_none) |> clean()
    weapon_model = :nitro.q(:weapon_model_wms_weapon_none) |> clean()
    owner = :nitro.q(:owner_wms_weapon_none) |> clean()
    storage_location = :nitro.q(:storage_location_wms_weapon_none) |> clean()
    status = :nitro.q(:status_wms_weapon_none) |> clean()
    license = :nitro.q(:license_wms_weapon_none) |> clean()

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

      WMS.WeaponRules.serial_number_exists?(serial_number) ->
        WMS.UI.show_error(:operator_error, "Помилка: зброя з таким серійним номером вже існує")

      true ->
        EXO.WMS.Weapons.event({:SaveWeapon, data})
        event(:init)
    end
  end

  def render_weapons(records) do
    :nitro.clear(:tableRow)

    Enum.each(records, fn weapon ->
      id = EXO.wms_weapon(weapon, :id)
      :nitro.insert_bottom(:tableRow, WMS.Weapon.Row.new(id, weapon, []))
    end)
  end

  def event({:Close, _data}) do
    :nitro.clear(:frms)
    :nitro.hide(:frms)
    render_toolbar(:list)
  end

  def event(:add_weapon) do
    render_toolbar({:form, "Додавання зброї"})
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

  def event({:EditWeapon, id}) do
    weapon = WMS.WeaponRules.find_weapon(id)

    if weapon != nil do
      :nitro.clear(:frms)

      render_toolbar({:form, "Редагування зброї: #{:nitro.to_binary(id)}"})

      :nitro.insert_bottom(
        :frms,
        NITRO.panel(id: :operator_error, body: [])
      )

      mod = WMS.Weapon.EditForm
      form = mod.new(:none, weapon, [])

      :nitro.insert_bottom(:frms, :form.new(form, weapon, create: true))
      :nitro.show(:frms)
    end
  end

  def event({:UpdateWeapon, id}) do
    weapon = WMS.WeaponRules.find_weapon(id)

    serial_number =
      :serial_number_wms_weapon_create
      |> :nitro.q()
      |> WMS.WeaponRules.clean()

    weapon_model =
      :weapon_model_wms_weapon_create
      |> :nitro.q()
      |> WMS.WeaponRules.clean()

    owner =
      :owner_wms_weapon_create
      |> :nitro.q()
      |> WMS.WeaponRules.clean()

    location =
      :storage_location_wms_weapon_create
      |> :nitro.q()
      |> WMS.WeaponRules.clean()

    license =
      :license_wms_weapon_create
      |> :nitro.q()
      |> WMS.WeaponRules.clean()

    cond do
      weapon == nil ->
        WMS.UI.show_error(:operator_error, "Помилка: зброю не знайдено")

      blank?(serial_number) ->
        WMS.UI.show_error(:operator_error, "Помилка: серійний номер обов’язковий")

      blank?(weapon_model) ->
        WMS.UI.show_error(:operator_error, "Помилка: модель зброї обов'язкова")

      blank?(owner) ->
        WMS.UI.show_error(:operator_error, "Помилка: власник обов’язковий")

      blank?(location) ->
        WMS.UI.show_error(:operator_error, "Помилка: локація зберігання обов’язкова")

      blank?(license) ->
        WMS.UI.show_error(:operator_error, "Помилка: ліцензія/дозвіл обов’язкова")

      WMS.WeaponRules.serial_number_used_by_another_weapon?(serial_number, id) ->
        WMS.UI.show_error(:operator_error, "Помилка: зброя з таким серійним номером вже існує")

      true ->
        updated_weapon =
          EXO.wms_weapon(
            weapon,
            serial_number: serial_number,
            weapon_model: weapon_model,
            owner: owner,
            storage_location: location,
            license: license
          )

        WMS.WeaponRules.update_weapon(updated_weapon)

        event(:init)
    end
  end

  def render_toolbar(:list) do
    :nitro.clear(:ctrl)
    :nitro.insert_bottom(:ctrl, WMS.Operator.Toolbar.list_mode())
  end

  def render_toolbar({:form, title}) do
    :nitro.clear(:ctrl)
    :nitro.insert_bottom(:ctrl, WMS.Operator.Toolbar.form_mode(title))
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
        NITRO.panel(class: :column20, body: "Статус"),
        NITRO.panel(class: :column10, body: "Дія")
      ]
    )
  end
end
