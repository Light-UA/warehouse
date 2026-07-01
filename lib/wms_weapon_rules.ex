defmodule WMS.WeaponRules do
  require EXO

  def normalize_id(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
  end

  def find_weapon(weapon_id) do
    wanted_id = normalize_id(weapon_id)

    :kvs.all(~c"/wms/weapons")
    |> Enum.find(fn weapon ->
      current_id =
        weapon
        |> EXO.wms_weapon(:id)
        |> normalize_id()

      current_id == wanted_id
    end)
  end

  def weapon_exists?(weapon_id) do
    find_weapon(weapon_id) != nil
  end

  def weapon_status(weapon_id) do
    weapon = find_weapon(weapon_id)

    if weapon != nil do
      weapon
      |> EXO.wms_weapon(:status)
      |> normalize_id()
    else
      nil
    end
  end

  def update_weapon(updated_weapon) do
    old_weapon = find_weapon(EXO.wms_weapon(updated_weapon, :id))

    if old_weapon != nil do
      :kvs.remove(old_weapon, ~c"/wms/weapons")
      :kvs.append(updated_weapon, ~c"/wms/weapons")
    end
  end

  def available_for_service?(weapon_id) do
    status = weapon_status(weapon_id)
    status == "active" or status == "На озброєнні"
  end

  def serial_number_used_by_another_weapon?(serial_number, current_weapon_id) do
    wanted_serial =
      serial_number
      |> clean()

      current_id =
        current_weapon_id
        |> clean()

    :kvs.all(~c"/wms/weapons")
    |> Enum.any?(fn weapon ->
      weapon_id =
        weapon
        |> EXO.wms_weapon(:id)
        |> clean()

        weapon_serial =
          weapon
          |> EXO.wms_weapon(:serial_number)
          |> clean()

        weapon_serial == wanted_serial and weapon_id != current_id
    end)
  end

  def clean(value) do
    value
    |> :nitro.to_binary()
    |> String.trim()
  end

  def available_for_transfer?(weapon_id) do
    status = weapon_status(weapon_id)
    status == "active" or status == "На озброєнні"
  end

  def serial_number_exists?(serial_number) do
    wanted =
      serial_number
      |> :nitro.to_binary()
      |> String.trim()

    :kvs.all(~c"/wms/weapons")
    |> Enum.any?(fn weapon ->
      current =
        weapon
        |> EXO.wms_weapon(:serial_number)
        |> :nitro.to_binary()
        |> String.trim()

      current == wanted
    end)
  end
end
