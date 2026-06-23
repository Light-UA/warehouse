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

  def available_for_service?(weapon_id) do
    status = weapon_status(weapon_id)
    status == "active" or status == "На озброєнні"
  end


  def available_for_transfer?(weapon_id) do
    status = weapon_status(weapon_id)
    status == "active" or status == "На озброєнні"
  end
end
