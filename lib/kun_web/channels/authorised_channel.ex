defmodule KunWeb.AuthorizedChannel do
  use KunWeb, :channel

  require Logger

  def join("authorized", _params, socket) do
    {:ok, socket}
  end

  def join("authorized:" <> auth_id, _params, socket) do
    #send(self(), :after_join)
    {
      :ok,
      %{},
      assign(socket, :authorized_id, auth_id)
    }
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("pong", _payload, socket) do
    socket
    |> Guardian.Phoenix.Socket.current_claims()
    |> Kun.UserManager.Guardian.decode_permissions_from_claims()
    |> Kun.UserManager.Guardian.any_permissions?(%{auth_test: [:p1]})
    |> allowed(socket, "pong")
  end

  def handle_in(:p3, _payload, socket) do
    socket
    |> Guardian.Phoenix.Socket.current_claims()
    #|> Kun.UserManager.Guardian.decode_permissions_from_claims()
    #|> Kun.UserManager.Guardian.any_permissions?(%{auth_test: [:p3]})
    |> allowed(socket, :p3)
  end

  def handle_in("ping", _payload, socket) do
    socket
    |> Guardian.Phoenix.Socket.current_claims()
    #|> Kun.UserManager.Guardian.decode_permissions_from_claims()
    #|> Kun.UserManager.Guardian.any_permissions?(%{auth_test: [:p2]})
    |> allowed(socket, "ping")
  end

  def allowed(true, socket, what) do
    Logger.info "#{inspect what} WAS ALLOWED ...."
    {:reply, {:ok, %{message: what}}, socket}
  end

  def allowed(false, socket, what) do
    push socket, "unauthorized:permissions", %{
      "error" => 403,
      "message" => "No permission to perform " <> what
    }
    Logger.info "terminating #{inspect socket}"
    {:stop, :shutdown , socket}
  end

end
