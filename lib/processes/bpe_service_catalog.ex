defmodule BPE.ServiceCatalog do
  require BPE

  def auth(_), do: true

  def def() do
    p = BPE.process(
      name: "ITSM Service Catalog Management",
      module: __MODULE__,
      flows: [
        BPE.sequenceFlow(id: "->Draft", source: "New", target: "Draft"),
        BPE.sequenceFlow(id: "Draft->Review", source: "Draft", target: "Review"),
        BPE.sequenceFlow(id: "Review->Active", source: "Review", target: "Active"),
        BPE.sequenceFlow(id: "Active->Inactive", source: "Active", target: "Inactive"),
        BPE.sequenceFlow(id: "Inactive->Archive", source: "Inactive", target: "Archive")
      ],
      tasks: [
        BPE.beginEvent(id: "New"),
        BPE.userTask(id: "Draft"),
        BPE.userTask(id: "Review"),
        BPE.userTask(id: "Active"),
        BPE.userTask(id: "Inactive"),
        BPE.endEvent(id: "Archive")
      ],
      beginEvent: "New",
      endEvent: "Archive"
    )

    BPE.process(p, tasks: :bpe_xml.fillInOut(BPE.process(p, :tasks), BPE.process(p, :flows)))
  end

  def action({:request, "New", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Draft", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Review", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Active", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Inactive", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Archive", _}, proc) do
    BPE.result(type: :stop, state: proc)
  end
end
