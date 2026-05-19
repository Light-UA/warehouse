defmodule Sample.WS do
  require N2O
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  get "/ws/*glob" do
    route_str = Enum.join(glob, "/")
    conn = Plug.Conn.fetch_cookies(conn)
    cookies = Enum.map(conn.req_cookies, fn {k, v} -> {k, v} end)

    req = %{
      path: conn.request_path,
      query_string: conn.query_string,
      cookies: cookies,
      headers: conn.req_headers
    }

    conn
    |> WebSockAdapter.upgrade(Sample.WS, [module: extract(route_str), req: req], timeout: 6_000)
    |> halt()
  end

  def extract(route), do: :application.get_env(:n2o, :router, EXO.Route).route(route)

  def init(args) do
    trace(args, "Sample.WS.init/1 args")

    try do
      module = Keyword.get(args, :module)

      if is_nil(module) do
        # Plug/Bandit startup validation
        {:ok, N2O.cx(module: nil, req: [])}
      else
        # WebSocket initialization
        req = Keyword.get(args, :req, %{})
        cookies = Map.get(req, :cookies, [])

        token =
          case :lists.keyfind("X-Auth-Token", 1, cookies) do
            {_, v} ->
              v

            _ -> ""
          end

        sid =
          case :n2o.depickle(token) do
            {{s, _}, _} -> s
            _ -> ""
          end

        ctx =
          N2O.cx(
            module: module,
            req: req,
            token: token,
            session: sid,
            handlers: [routes: :application.get_env(:n2o, :routes, EXO.Route)]
          )

        trace(ctx, "Sample.WS.init/1 ctx before Route.init")

        case EXO.Route.init([], ctx) do
          {:ok, _, final_ctx} ->
            trace(final_ctx, "Sample.WS.init/1 final_ctx")
            {:ok, final_ctx}

          other ->
            trace(other, "Sample.WS.init/1 Route.init unexpected return")
            {:error, :route_init_failed}
        end
      end
    rescue
      e ->
        trace(e, "Sample.WS.init/1 RESCUED ERROR")
        trace(__STACKTRACE__, "Sample.WS.init/1 STACKTRACE")
        reraise e, __STACKTRACE__
    catch
      kind, payload ->
        trace({kind, payload}, "Sample.WS.init/1 CAUGHT THROW")
        trace(__STACKTRACE__, "Sample.WS.init/1 STACKTRACE")
        :erlang.raise(kind, payload, __STACKTRACE__)
    end
  end

  def handle_in(msg, state) do
    trace(msg, "Sample.WS.handle_in msg")

    try do
      case msg do
        {"N2O," <> _ = message, _} ->
          response(:n2o_proto.stream({:text, message}, [], state))

        {"PING", _} ->
          {:reply, :ok, {:text, "PONG"}, state}

        {message, _} when is_binary(message) ->
          response(:n2o_proto.stream({:binary, message}, [], state))

        other ->
          trace(other, "Sample.WS.handle_in unexpected pattern")
          {:ok, state}
      end
    rescue
      e ->
        trace(e, "Sample.WS.handle_in RESCUED ERROR")
        trace(__STACKTRACE__, "Sample.WS.handle_in STACKTRACE")
        reraise e, __STACKTRACE__
    end
  end

  def handle_info(message, state) do
    trace(message, "Sample.WS.handle_info msg")

    try do
      response(:n2o_proto.info(message, [], state))
    rescue
      e ->
        trace(e, "Sample.WS.handle_info RESCUED ERROR")
        trace(__STACKTRACE__, "Sample.WS.handle_info STACKTRACE")
        reraise e, __STACKTRACE__
    end
  end

  def terminate(reason, state) do
    trace({reason, state}, "Sample.WS.terminate")
    :ok
  end

  defp trace(term, label) do
    if :application.get_env(:n2o, :trace, false) do
      IO.inspect(term, label: label)
    else
      term
    end
  end

  def response({:reply, {:binary, rep}, _, s}), do: {:reply, :ok, {:binary, rep}, s}
  def response({:reply, {:text, rep}, _, s}), do: {:reply, :ok, {:text, rep}, s}

  def response({:reply, {:bert, rep}, _, s}),
    do: {:reply, :ok, {:binary, :n2o_bert.encode(rep)}, s}

  def response({:reply, {:json, rep}, _, s}),
    do: {:reply, :ok, {:binary, :n2o_json.encode(rep)}, s}

  match _ do
    send_resp(conn, 404, "Please refer to https://n2o.dev for more information.")
  end
end
