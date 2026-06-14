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

  def route(<<"app/backoffice/wms_weapons", _::binary>>), do: EXO.WMS.Weapons
  def route(<<"app/wms/console", _::binary>>), do: EXO.WMS.Console

  # WMS Portals

  # WMS Portals

  def route(<<"app/wms/operator/weapons", _::binary>>), do: EXO.WMS.Weapons
  def route(<<"app/wms/parts", _::binary>>), do: EXO.WMS.Parts
  def route(<<"app/wms/repair/orders", _::binary>>), do: EXO.WMS.Services
  def route(<<"app/wms/logistics/transfers", _::binary>>), do: EXO.WMS.Transfers
  def route(<<"app/wms/operator", _::binary>>), do: EXO.WMS.Operator
  def route(<<"app/wms/repair", _::binary>>), do: EXO.WMS.Repair
  def route(<<"app/wms/logistics", _::binary>>), do: EXO.WMS.Logistics
  def route(<<"app/wms/service_events", _::binary>>), do: EXO.WMS.ServiceEvents
  # Login

  def route(<<"app/login", _::binary>>), do: EXO.Login
  def route(""), do: EXO.Login
  def route(_), do: EXO.Login
end
