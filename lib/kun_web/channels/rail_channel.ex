defmodule KunWeb.RailChannel do
  use KunWeb, :channel

  require Logger

  def join("rail", _params, socket) do
    {:ok, socket}
  end

  def join("rail:" <> user_id, _params, socket) do
    #send(self(), :after_join)
    { :ok, %{}, assign(socket, :rail_id, user_id) }
  end

  def handle_in("pong", _payload, socket) do
    response(true, socket, "pong")
  end

  def handle_in(:xrpl, payload, socket) do
    token = socket.assigns[:guardian_token]
    case Kun.UserManager.Guardian.decode_and_verify(token) do
      {:ok, _} ->
        ledger(true, socket, payload)
      {:error, _} ->
        ledger(false, socket, "Token verification error.")
    end
  end

  def ledger(true, socket, payload) do
    #Logger.warn "#{inspect payload} WAS ALLOWED ...."
    :poolboy.transaction(:xrp_ledger_pool,
      fn(pid) -> :gen_server.call(pid, {:transaction, socket, payload}) end)

    {:reply, {:ok, %{message: "sent to server"}}, socket}
  end

  def ledger(false, socket, what) do
    push socket, "unauthorized:permissions", %{
      "error" => 403,
      "message" => "No permission to perform. " <> what
    }
    Logger.info "terminating #{inspect socket}"
    {:stop, :shutdown , socket}
  end

  def response(true, socket, what) do
    #Logger.warn "#{inspect what} WAS ALLOWED ...."
    #user = Guardian.Phoenix.Socket.current_resource(socket)
    #Logger.warn "Current Resource for this token #{inspect user}"

    {:reply, {:ok, %{message: what}}, socket}
  end

  def response(false, socket, what) do
    push socket, "unauthorized:permissions", %{
      "error" => 403,
      "message" => "No permission to perform. " <> what
    }
    Logger.info "terminating #{inspect socket}"
    {:stop, :shutdown , socket}
  end

end
