defmodule KunWeb.LoginChannel do
  use KunWeb, :channel

  require Logger

  ## This channel will be used to return JWT to the JS client. JWT is generated during
  ## Socket Connection and is in socket.assignes: socket.assigns[:token]
  ## socket |> assign(:hardware_id, hardware_id) |> assign(:guardian_token, jwt) }
  ##
  def join("login:" <> _user_id,  %{"name" => _username} , socket) do
    # if error is in assigned push error message
    login_error = socket.assigns[:login_error]
    guardian_token = socket.assigns[:guardian_default_token]
    Logger.info" > jwt #{inspect guardian_token}"
    decide(socket,login_error,guardian_token)
  end

  def terminate(reason, socket) do
    Logger.warn" > leave #{inspect reason}  #{inspect socket}"
    :ok
  end

  def handle_info({:reply_with_token,  %{guardian_token: guardian_token, user: user}}, socket) do
    Logger.info ":reply_with_token - received .... sending user: #{inspect user}"
    push socket, "user:guardian_token", user |> Map.put(:guardian_token, guardian_token)
    {:noreply, socket }
  end

  def handle_info({:logout, errors }, socket) do
    # TODO revoke token?
    push socket, "login:unauthorized", %{
      "error" => 403,
      "message" => "Unauthorized"
    }
    Logger.debug "terminating #{inspect socket}"
    {:stop, {:shutdown, {:logout, errors}}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # TODO handle refresh token here?
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{message: "pong"}}, socket}
  end

  def handle_in("logout",
    %{"guardian_token" => token} , socket) do
    # TODO make it simpler! just revoke?
    #Logger.warn "Attempting to logout #{inspect token}"
    #{ :ok, claims } = Kun.UserManager.Guardian.decode_and_verify(token)

    #Logger.warn "Completing to logout #{inspect claims}"
    {:exit, {:shutdown, {:logout, token}}, socket}
  end

  defp decide(socket, nil, guardian_token) do
    user = socket.assigns[:user]
    #    Logger.debug " user from assigns:  #{inspect user}"
    # Logger.debug " guardian_token:  #{inspect guardian_token}"
    # invoke handle info bellow passing jwt and
    send(self(), {:reply_with_token, %{guardian_token: guardian_token, user: user}})
    {:ok, socket}
  end

  defp decide(socket, login_error, nil) do
    send(self(), {:logout, login_error})
    {:ok, socket}
  end
end
