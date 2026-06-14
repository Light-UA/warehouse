defmodule WMS.Weapon.Row do
  require EXO
  require NITRO
  require FORM

  def id(), do: EXO.wms_weapon()
  def doc(), do: "Форма реєстрації зброї (таблична частина)"

  def status_title("active"), do: "На озброєнні"
  def status_title("repair"), do: "На ремонті"
  def status_title("maintenance"), do: "На обслуговуванні"
  def status_title("destroyed"), do: "Знищено"
  def status_title("decommissioned"), do: "Списана"
  def status_title(value), do: value

  def new(name, weapon, _) do
    id = EXO.wms_weapon(weapon, :id)
    serial_number = EXO.wms_weapon(weapon, :serial_number)
    model = EXO.wms_weapon(weapon, :weapon_model)
    owner = EXO.wms_weapon(weapon, :owner)
    license = EXO.wms_weapon(weapon, :license)
    storage_location = EXO.wms_weapon(weapon, :storage_location)
    status = EXO.wms_weapon(weapon, :status)

    status_value =
      status
      |> :nitro.to_binary()
      |> String.trim()

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(serial_number)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(model)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(owner)),
        NITRO.panel(class: :column10, body: :nitro.to_binary(license)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(storage_location)),
        NITRO.panel(class: :column20, body: status_title(status_value))
      ]
    )
  end
end
