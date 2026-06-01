defmodule BPE.Incident do
  require BPE
  require Logger

  def auth(_), do: true

  def def() do
    p = BPE.process(
      name: "ITSM Incident Management",
      module: __MODULE__,
      flows: [
        BPE.sequenceFlow(id: "->Triaje", source: "New", target: "Triaje"),
        BPE.sequenceFlow(id: "Triaje->Work", source: "Triaje", target: "Work"),
        BPE.sequenceFlow(id: "Work->Escalate", source: "Work", target: "Escalate"),
        BPE.sequenceFlow(id: "Escalate->Work", source: "Escalate", target: "Work"),
        BPE.sequenceFlow(id: "Work->Resolve", source: "Work", target: "Resolve"),
        BPE.sequenceFlow(id: "Resolve->Closed", source: "Resolve", target: "Closed")
      ],
      tasks: [
        BPE.beginEvent(id: "New"),
        BPE.userTask(id: "Triaje"),
        BPE.userTask(id: "Work"),
        BPE.serviceTask(id: "Escalate"),
        BPE.userTask(id: "Resolve"),
        BPE.endEvent(id: "Closed")
      ],
      beginEvent: "New",
      endEvent: "Closed",
      events: [
        BPE.boundaryEvent(id: :*, timeout: BPE.timeout(spec: {0, {4, 0, 0}}))
      ]
    )

    BPE.process(p, tasks: :bpe_xml.fillInOut(BPE.process(p, :tasks), BPE.process(p, :flows)))
  end

  def action({:request, "New", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Triaje", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Work", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Escalate", _}, proc) do
    Logger.info("Incident Escalation Triggered")
    BPE.result(
      type: :reply,
      reply: "Work",
      state: BPE.process(proc, docs: [{:escalated, true} | BPE.process(proc, :docs)])
    )
  end

  def action({:request, "Resolve", _}, proc) do
    BPE.result(type: :reply, state: proc)
  end

  def action({:request, "Closed", _}, proc) do
    BPE.result(type: :stop, state: proc)
  end
end
