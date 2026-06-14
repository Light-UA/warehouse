defmodule WMS.Part.Row do
  require EXO
  require NITRO
  require FORM

  def id(), do: EXO.wms_part()

  @spec doc() :: <<_::712>>
  def doc(), do: "Форма деталі/запчастини зброї (таблична частина)"

  def new(name, part, _) do
    id = EXO.wms_part(part, :id)
    serial_number = EXO.wms_part(part, :serial_number)
    part_type = EXO.wms_part(part, :part_type)
    part_status = EXO.wms_part(part, :part_status)
    installed_in_weapon = EXO.wms_part(part, :installed_in_weapon)
    storage_location = EXO.wms_part(part, :storage_location)
    manufacturer = EXO.wms_part(part, :manufacturer)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(serial_number)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(part_type)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(part_status)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(installed_in_weapon)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(storage_location)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(manufacturer))

      ]
    )
  end
end
