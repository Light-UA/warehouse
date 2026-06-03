import Config

config :n2o,
  pickler: :n2o_secret,
  app: :warehouse,
  mq: :n2o_syn,
  port: 8051,
  trace: false,
  tables: [:cookies, :file, :caching, :async],
  protocols: [:n2o_heart, :nitro_n2o, :n2o_ftp],
  routes: EXO.Route

config :kvs,
  dba: :kvs_rocks,
  dba_st: :kvs_st,
  schema: [:kvs, :kvs_stream, :bpe_metainfo, EXO]

config :form,
  module: :form_backend,
  registry: [
    BPE.Create,
    BPE.Pass,
    BPE.Row,
    BPE.Trace,
    Client.Row,
    Client.Form,
    Program.Form,
    Program.Row,
    Account.Form,
    WMS.Weapon.Form,
    WMS.Weapon.Row,
    WMS.ServiceOrder.Form,
    WMS.ServiceOrder.Row
  ]

config :bpe,
  procmodules: [
    :bpe,
    :bpe_account,
    WMS.BPE.ServiceOrder,
    WMS.BPE.LogisticsOrder,
    WMS.BPE.IncomeOrder,
    WMS.BPE.TerminationOrder
  ],
  logger_level: :info,
  logger: [
    {:handler, :synrc, :logger_std_h,
     %{
       level: :info,
       id: :synrc,
       max_size: 2000,
       module: :logger_std_h,
       config: %{type: :file, file: ~c"exo.log"},
       formatter:
         {:logger_formatter,
          %{
            template: [:time, ~c" ", :pid, ~c" ", :module, ~c" ", :msg, ~c"\n"],
            single_line: true
          }}
     }}
  ]
