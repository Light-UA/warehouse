defmodule EXO.ITSM.Services do
  require EXO
  require NITRO
  require Logger

  def event(:init) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)
    :nitro.insert_top(:tableHead, header())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)

    mod = ITSM.Service.Form
    form = :form.new(mod.new(mod, mod.id(), []), mod.id(), [])
    :nitro.insert_bottom(:frms, form)

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(id: :creator, body: "Новий сервіс", postback: :create, class: [:button, :sgreen])
    )

    :nitro.hide(:frms)

    :lists.map(
      fn x ->
        :nitro.insert_top(
          :tableRow,
          ITSM.Service.Row.new(:form.atom([:row, EXO.itsm_service(x, :id)]), x, [])
        )
      end,
      :kvs.all(~c"/itsm/services")
    )
  end

  def event(:create) do
    :nitro.hide(:ctrl)
    :nitro.show(:frms)
  end

  def event({:CreateService, _}) do
    name = :name_itsm_service_none |> :nitro.q()
    desc = :description_itsm_service_none |> :nitro.q()
    owner = :owner_itsm_service_none |> :nitro.q()
    status = :status_itsm_service_none |> :nitro.q()
    id = :kvs.seq([], [])

    service = EXO.itsm_service(id: id, name: name, description: desc, owner: owner, status: status)
    :kvs.append(service, ~c"/itsm/services")

    row = ITSM.Service.Row.new(:form.atom([:row, id]), service, [])
    :nitro.insert_top(:tableRow, :form.new(row, service, []))

    # Trigger BPE process creation (optional, for demo process engine integration)
    try do
      :bpe.start(BPE.ServiceCatalog.def(), [service])
    rescue
      err -> Logger.warning("BPE start failed for service catalog: #{inspect(err)}")
    end

    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event({:Close, []}) do
    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event(x) do
    Logger.info("Services event: #{inspect(x)}")
  end

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column10, style: "width: 10%; word-break: break-all; white-space: normal;", body: "Номер"),
        NITRO.panel(class: :column20, style: "width: 15%; white-space: normal;", body: "Назва сервісу"),
        NITRO.panel(class: :column20, style: "width: 55%; white-space: normal;", body: "Опис сервісу"),
        NITRO.panel(class: :column12, style: "width: 12%; white-space: normal;", body: "Власник"),
        NITRO.panel(class: :column10, style: "width: 8%; white-space: normal;", body: "Статус")
      ]
    )
  end
end
