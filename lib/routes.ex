defmodule EXO.Route do
  require N2O
  require Logger

  def finish(state, ctx), do: {:ok, state, ctx}

  def init(state, context) do
    %{path: path} = N2O.cx(context, :req)
    {:ok, state, N2O.cx(context, path: path, module: ws(path))}
  end

  def ws(<<"/ws/", p::binary>>), do: route(p)
  def ws(<<"/", p::binary>>), do: route(p)
  def ws(p), do: route(p)

  # Administrator

  def route(<<"app/admin/kvs", _::binary>>), do: ADM.KVS
  def route(<<"app/admin/n2o", _::binary>>), do: ADM.N2O
  def route(<<"app/admin/mnesia", _::binary>>), do: ADM.MNESIA
  def route(<<"app/admin/form", _::binary>>), do: ADM.FORM
  def route(<<"app/admin/bpe", _::binary>>), do: ADM.BPE
  def route(<<"app/admin/process", _::binary>>), do: ADM.ACT

  # Backoffice

  def route(<<"app/backoffice/reports", _::binary>>), do: EXO.Login
  def route(<<"app/backoffice/tariffs", _::binary>>), do: EXO.Tariffs
  def route(<<"app/backoffice/domains", _::binary>>), do: EXO.Domains
  def route(<<"app/backoffice/itsm_services", _::binary>>), do: EXO.ITSM.Services
  def route(<<"app/backoffice/itsm_incidents", _::binary>>), do: EXO.ITSM.Incidents
  def route(<<"app/backoffice/itsm_changes", _::binary>>), do: EXO.ITSM.Changes
  def route(<<"app/backoffice/console", _::binary>>), do: EXO.ITSM.Console
  def route(<<"app/backoffice/profile", _::binary>>), do: EXO.User
  def route(<<"app/backoffice/user", _::binary>>), do: EXO.User

  # Consumer

  def route(<<"app/consumer/profile", _::binary>>), do: EXO.Login
  def route(<<"app/consumer/consume", _::binary>>), do: EXO.Login
  def route(<<"app/consumer/service", _::binary>>), do: EXO.Service
  def route(<<"app/consumer/portal", _::binary>>), do: EXO.ITSM.Portal

  # Login

  def route(<<"app/login", _::binary>>), do: EXO.Login
  def route(""), do: EXO.Login
  def route(_), do: EXO.Login
end
