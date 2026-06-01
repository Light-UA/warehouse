defmodule BPE.Change do
  require BPE
  require Logger

  def auth(_), do: true

  def def() do
    p = BPE.process(
      name: "ITSM Change Management",
      module: __MODULE__,
      flows: [
        BPE.sequenceFlow(id: "->Analyze", source: "New", target: "Analyze"),
        BPE.sequenceFlow(id: "Analyze->Plan", source: "Analyze", target: "Plan"),
        BPE.sequenceFlow(id: "Plan->Approve", source: "Plan", target: "Approve"),
        BPE.sequenceFlow(id: "Approve->Execute", source: "Approve", target: "Execute"),
        BPE.sequenceFlow(id: "Execute->Verify", source: "Execute", target: "Verify"),
        BPE.sequenceFlow(id: "Verify->Closed", source: "Verify", target: "Closed"),
        BPE.sequenceFlow(id: "Execute->Rollback", source: "Execute", target: "Rollback"),
        BPE.sequenceFlow(id: "Rollback->Analyze", source: "Rollback", target: "Analyze")
      ],
      tasks: [
        BPE.beginEvent(id: "New"),
        BPE.userTask(id: "Analyze"),
        BPE.userTask(id: "Plan"),
        BPE.userTask(id: "Approve"),
        BPE.userTask(id: "Execute"),
        BPE.serviceTask(id: "Rollback"),
        BPE.userTask(id: "Verify"),
        BPE.endEvent(id: "Closed")
      ],
      beginEvent: "New",
      endEvent: "Closed",
      events: [
        BPE.boundaryEvent(id: :*, timeout: BPE.timeout(spec: {0, {72, 0, 0}}))
      ]
    )

    BPE.process(p, tasks: :bpe_xml.fillInOut(BPE.process(p, :tasks), BPE.process(p, :flows)))
  end

  def action({:request, "New", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Analyze", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Plan", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Approve", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Execute", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Rollback", _}, proc) do
    Logger.warning("Change Rollback Execution Triggered")
    BPE.result(
      type: :reply,
      reply: "Analyze",
      state: BPE.process(proc, docs: [{:rolled_back, true} | BPE.process(proc, :docs)])
    )
  end

  def action({:request, "Verify", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Closed", _}, proc) do
    BPE.result(type: :stop, state: proc)
  end
end
