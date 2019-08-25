defmodule KunWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "authorized:*", KunWeb.AuthorizedChannel
  channel "login:*", KunWeb.LoginChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  require Logger

  @doc """
  Connect for initial login
  """
  def connect(%{"email" => email,
                "password" => password } , socket) do
    # Verify login - find user in the DB
    case Kun.UserManager.authenticate(email, password) do
      {:ok, user} ->
        process_auth_resp(user, "", socket)
      {:error} -> :error
    end
    #|> process_auth_resp(sUID , socket)
    # TODO have users/permissions stored in K/V store
  end

  @doc """
  Connect with existing JWT token
  """
  def connect(%{"token" => token}, socket) do
    case Guardian.Phoenix.Socket.authenticate(socket, Kun.UserManager.Guardian, token) do
      {:ok, authed_socket} ->
        {:ok, authed_socket}
      {:error, _} -> :error
	  end
  end

  # This function will be called when there was no authentication information
  def connect(_params, _socket) do
    :error
  end

  defp process_auth_resp(%{ permissions: nil } = _user, sUID, socket) do
    Logger.info "Can't authenticate user! #{inspect sUID} -> no permissions!"
    {:ok, socket
    |> assign(:user_id, 0)
    |> assign(:login_error, sUID)}
  end

  defp process_auth_resp(%{ id: _id, name: _name } = user, _sUID, socket) do
    Logger.warn "Found user:  #{inspect user}"
    {:ok, jwt, claims} = Kun.UserManager.Guardian.encode_and_sign(user)
    # Logger.warn "Claims :  #{inspect claims}"
    {:ok, socket
              |> Guardian.Phoenix.Socket.assign_rtc(user, jwt, claims)
              |> assign(:guardian_token, jwt)
              |> assign(:user_id, user.id)
              |> assign(:user, user )
    }
  end

  defp process_auth_resp({:error, :user_not_found}, sUID, socket) do
    Logger.info "Can't authenticate user! #{inspect sUID} - user not found"
    {:ok, socket
    |> assign(:user_id, 0)
    |> assign(:login_error, sUID)}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     KunWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil

  #def id(socket), do:  "user_socket:#{socket.assigns.user_id}"
end
