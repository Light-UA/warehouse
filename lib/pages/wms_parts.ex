defmodule EXO.WMS.Parts do
  require EXO
  require NITRO
  require Logger

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.insert_top(:tableHead, header())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)

    build_form()

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :creator,
        body: "Додати деталь",
        postback: :create,
        class: [:button, :sgreen]
      )
    )

    :nitro.hide(:frms)

    :lists.map(
      fn x ->
        :nitro.insert_top(
          :tableRow,
          WMS.Part.Row.new(:form.atom([:row, EXO.wms_part(x, :id)]), x, [])
        )
      end,
      :kvs.all(~c"/wms/parts")
    )
  end

  def build_form() do
    :nitro.clear(:frms)

    :nitro.insert_bottom(
      :frms,
      NITRO.panel(id: :part_error, body: [])
    )

    mod = WMS.Part.Form
    form = :form.new(mod.new(:none, mod.id(), []), mod.id(), [])
    :nitro.insert_bottom(:frms, form)
  end

  def show_error(message) do
    :nitro.clear(:part_error)

    :nitro.insert_bottom(
      :part_error,
      NITRO.panel(
        class: :validation_error,
        body: message
      )
    )
  end

  def event(:create) do
    build_form()
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
  end

  @spec weapon_exists(any()) :: boolean()
  def weapon_exists(weapon_id) do
    :kvs.all(~c"/wms/weapons")
    |> Enum.any?(fn weapon ->
      :nitro.to_binary(EXO.wms_weapon(weapon, :id)) == :nitro.to_binary(weapon_id)
    end)
  end

  def event({:SavePart, _}) do
    :nitro.clear(:part_error)

    serial_number = :serial_number_wms_part_none |> :nitro.q()
    part_type = :part_type_wms_part_none |> :nitro.q()
    part_status = :part_status_wms_part_none |> :nitro.q()
    installed_in_weapon = :installed_in_weapon_wms_part_none |> :nitro.q()
    storage_location = :storage_location_wms_part_none |> :nitro.q()
    manufacturer = :manufacturer_wms_part_none |> :nitro.q()

    if installed_in_weapon != [] and not weapon_exists(installed_in_weapon) do
      show_error("Помилка: зброї з таким ID не існує")
    else
      id = :kvs.seq([], [])

      part =
        EXO.wms_part(
          id: id,
          serial_number: serial_number,
          part_type: part_type,
          part_status: part_status,
          installed_in_weapon: installed_in_weapon,
          storage_location: storage_location,
          manufacturer: manufacturer
        )

      :kvs.append(part, ~c"/wms/parts")

      row = WMS.Part.Row.new(:form.atom([:row, id]), part, [])
      :nitro.insert_top(:tableRow, :form.new(row, part, []))

      build_form()

      :nitro.hide(:frms)
      :nitro.show(:ctrl)
    end
  end

  def event({:Close, []}) do
    build_form()
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(x) do
    Logger.info("Parts event: #{inspect(x)}")
  end

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, body: "ID"),
        NITRO.panel(class: :column20, body: "Серійний номер"),
        NITRO.panel(class: :column20, body: "Тип"),
        NITRO.panel(class: :column20, body: "Статус"),
        NITRO.panel(class: :column20, body: "ID зброї"),
        NITRO.panel(class: :column20, body: "Локація"),
        NITRO.panel(class: :column20, body: "Виробник")
      ]
    )
  end
end
