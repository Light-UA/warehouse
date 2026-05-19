defmodule EXO.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :exosculat,
      version: "4.5.6",
      description: "EXO Exosculat Exoskeleton",
      package: package(),
 overrides: [
      {:rocksdb,
       [
         {:pre_hooks, [{:compile, "patch -N -p1 < ../../../../patches/rocksdb-snappy.patch || true"}]}
       ]}
    ],
      deps: deps()
    ]
  end

  def package() do
    [
      files: ~w(doc include priv mix.exs LICENSE CNAME README.md),
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/erpuno/exo"}
    ]
  end

  def application(),
    do: [
      mod: {EXOSCULAT, []},
      extra_applications: [:rocksdb, :mnesia, :syn, :bpe, :nitro, :form, :n2o]
    ]

  def deps() do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:plug, "~> 1.15.3"},
      {:bandit, "~> 1.0"},
      {:websock_adapter, "~> 0.5"},
      {:rocksdb, "~> 2.6.2"},
      # Transitional Erlang-Elixir Tier Stack
      {:form, "~> 11.4.15"},
      {:bpe, "~> 8.12.4"},
      {:nitro, "~> 11.4.16"},
      {:kvs, "~> 10.8.3"},
      {:n2o, "~> 10.12.4"},
      {:syn, "2.1.0"}
    ]
  end
end
