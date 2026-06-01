defmodule EXO do
  require KVS
  require FORM
  require Record

  Module.register_attribute(__MODULE__, :exo_fields_accum, accumulate: true)

  @schema [
    :account,
    :client,
    :card,
    :transaction,
    :currency,
    :field,
    :program,
    :phone,
    :itsm_service,
    :itsm_req,
    :itsm_incident,
    :itsm_change,
    :itsm_ci,
    :itsm_sla
  ]

  Enum.each(
    @schema,
    fn t ->
      Enum.each(
        Record.extract_all(
          from_lib:
            "exosculat/include/" <> :erlang.list_to_binary(:erlang.atom_to_list(t)) <> ".hrl"
        ),
        fn {name, definition} ->
          Record.defrecord(name, definition)
          Module.put_attribute(__MODULE__, :exo_fields_accum, {name, definition})
        end
      )
    end
  )

  def exo_fields(), do: @exo_fields_accum

  def boot() do
    try do
      EXO.Boot.clients()
      EXO.Boot.programs()
      EXO.Boot.accounts()
      EXO.Boot.itsm()
    rescue
      _ -> :skip
    end
  end

  def metainfo(), do: KVS.schema(name: :exo, tables: exo())

  def table(name) do
    {a, b} = :lists.unzip(:proplists.get_value(name, exo_fields(), []))
    KVS.table(name: name, fields: a, instance: b)
  end

  def exo(), do: :lists.map(fn x -> table(x) end, @schema)
end
