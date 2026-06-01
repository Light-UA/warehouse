defmodule EXOSCULAT do
  use Application
  use Supervisor

  def stop(_), do: :ok
  def init([]), do: {:ok, {{:one_for_one, 5, 10}, []}}

  def start(_, _) do
    children = [
      {Bandit, scheme: :http, port: 8051, plug: Sample.WS},
      {Bandit, scheme: :http, port: 8004, plug: Sample.Static}
    ]

    result = Supervisor.start_link(children, strategy: :one_for_one, name: Sample.Supervisor)

    # Seed demo data on startup (idempotent — skips already-populated feeds)
    Task.start(fn ->
      :timer.sleep(500)
      EXO.boot()
    end)

    result
  end
end
