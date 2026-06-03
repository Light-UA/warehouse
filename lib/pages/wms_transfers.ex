defmodule EXO.WMS.Transfers do
  require EXO
  require NITRO
  require FORM

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.clear(:ctrl)
    :nitro.clear(:frms)

    :nitro.insert_top(
      :tableHead,
      NITRO.panel(
        id: :header,
        class: :th,
        body: [
          NITRO.panel(class: :column10, body: "ID"),
          NITRO.panel(class: :column20, body: "WEAPON"),
          NITRO.panel(class: :column20, body: "FROM STORAGE"),
          NITRO.panel(class: :column30, body: "TO STORAGE"),
          NITRO.panel(class: :column20, body: "STATUS")
        ]
      )
    )

    :nitro.insert_bottom(:ctrl, NITRO.link(id: :new_order, body: "Новий наряд", postback: :new_order, class: [:button, :sgreen]))
    :nitro.hide(:frms)

    records = :kvs.all(EXO.wms_transfer())
    Enum.each(records, fn order ->
      id = EXO.wms_transfer(order, :id)
      :nitro.insert_bottom(:tableRow, WMS.TransferOrder.Row.new(id, order, []))
    end)
  end

  def event({:CreateTO, _form}) do
    id = :kvs.seq([], [])
    weapon = :nitro.to_binary(:nitro.q(:weapon_wms_transfer_none))
    from_storage = :nitro.to_binary(:nitro.q(:from_storage_wms_transfer_none))
    to_storage = :nitro.to_binary(:nitro.q(:to_storage_wms_transfer_none))
    order = EXO.wms_transfer(
      id: id,
      weapon: weapon,
      from_storage: from_storage,
      to_storage: to_storage,
      transfer_status: "Init"
    )
    :kvs.put(order)
    :nitro.insert_bottom(:tableRow, WMS.TransferOrder.Row.new(id, order, []))
    # Init BPE Process
    :bpe.start(WMS.BPE.LogisticsOrder.def(), [])
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(:new_order) do
    :nitro.hide(:ctrl)
    :nitro.clear(:frms)
    mod = WMS.TransferOrder.Form
    form = mod.new(:none, mod.id(), [])
    :nitro.insert_bottom(:frms, :form.new(form, mod.id(), []))
    :nitro.show(:frms)
  end

  def event({:Close, _}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end
  def event(_), do: :ok
end
