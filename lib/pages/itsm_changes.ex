defmodule EXO.ITSM.Changes do
  require EXO
  require NITRO
  require Logger

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.insert_top(:tableHead, header())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)

    mod = ITSM.Change.Form
    form = :form.new(mod.new(mod, mod.id(), []), mod.id(), [])
    :nitro.insert_bottom(:frms, form)

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(id: :creator, body: "Створити запит на зміну", postback: :create, class: [:button, :sgreen])
    )

    :nitro.hide(:frms)

    :lists.map(
      fn x ->
        :nitro.insert_top(
          :tableRow,
          ITSM.Change.Row.new(:form.atom([:row, EXO.itsm_change(x, :id)]), x, [])
        )
      end,
      :kvs.all(~c"/itsm/changes")
    )
  end

  def event(:create) do
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
  end

  def event({:CreateChange, _}) do
    req = :req_itsm_change_none |> :nitro.q()
    service = :service_itsm_change_none |> :nitro.q()
    title = :title_itsm_change_none |> :nitro.q()
    desc = :description_itsm_change_none |> :nitro.q()
    risk = :risk_level_itsm_change_none |> :nitro.q()
    impact = :impact_itsm_change_none |> :nitro.q()
    status = :status_itsm_change_none |> :nitro.q()
    manager = :change_manager_itsm_change_none |> :nitro.q()
    backout = :backout_plan_itsm_change_none |> :nitro.q()
    id = :kvs.seq([], [])

    change = EXO.itsm_change(
      id: id,
      req: req,
      service: service,
      title: title,
      description: desc,
      risk_level: risk,
      impact: impact,
      status: status,
      change_manager: manager,
      backout_plan: backout
    )
    :kvs.append(change, ~c"/itsm/changes")

    row = ITSM.Change.Row.new(:form.atom([:row, id]), change, [])
    :nitro.insert_top(:tableRow, :form.new(row, change, []))

    # Trigger BPE process creation
    try do
      :bpe.start(BPE.Change.def(), [change])
    rescue
      err -> Logger.warning("BPE start failed for change: #{inspect(err)}")
    end

    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event({:Close, []}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(x) do
    Logger.info("Changes event: #{inspect(x)}")
  end

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, body: "Номер"),
        NITRO.panel(class: :column10, body: "Сервіс"),
        NITRO.panel(class: :column30, body: "Зміна"),
        NITRO.panel(class: :column10, body: "Ризик"),
        NITRO.panel(class: :column10, body: "Вплив"),
        NITRO.panel(class: :column10, body: "Статус"),
        NITRO.panel(class: :column20, body: "Менеджер")
      ]
    )
  end
end
