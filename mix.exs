defmodule EXO.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :warehouse,
      version: "4.5.6",
      description: "WMS Warehouse Management System",
      package: package(),
      deps: deps()
    ]
  end

  def package() do
    [
      files: ~w(doc include priv mix.exs LICENSE CNAME README.md),
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/erpuno/wms"}
    ]
  end

  def application(),
    do: [
      mod: {WAREHOUSE, []},
      extra_applications: [:rocksdb, :mnesia, :syn, :bpe, :nitro, :form, :n2o]
    ]

  def deps() do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:plug, "~> 1.18"},
      {:bandit, "~> 1.11"},
      {:websock_adapter, "~> 0.5"},
      {:rocksdb, github: "emqx/erlang-rocksdb", tag: "1.8.0-emqx-11", override: true},
      {:form, "~> 11.4.15"},
      {:bpe, "~> 8.12.4"},
      {:nitro, "~> 11.4.16"},
      {:kvs, "~> 10.8.3"},
      {:n2o, "~> 10.12.4"},
      {:syn, "2.1.0"}
    ]
  end
end