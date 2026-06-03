defmodule WMS.TransferOrder.Row do
  require EXO
  require NITRO

  def id(), do: EXO.wms_transfer()
  def doc(), do: "Форма наряду на переміщення (таблична частина)"
  def new(name, transfer_order, _) do
    id = EXO.wms_transfer(transfer_order, :id)
    weapon = EXO.wms_transfer(transfer_order, :weapon)
    from_storage = EXO.wms_transfer(transfer_order, :from_storage)
    to_storage = EXO.wms_transfer(transfer_order, :to_storage)
    status = EXO.wms_transfer(transfer_order, :transfer_status)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(class: :column10, body: :nitro.to_binary(id)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(weapon)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(from_storage)),
        NITRO.panel(class: :column30, body: :nitro.to_binary(to_storage)),
        NITRO.panel(class: :column20, body: :nitro.to_binary(status))
      ]
    )
  end
end
