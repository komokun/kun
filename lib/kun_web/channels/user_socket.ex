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
    Kun.UserManager.authenticate(email, password)
    |> process_auth_resp(socket)
  end

  @doc """
  Connect with existing JWT token
  """

  def connect(%{"token" => token}, socket) do

    case Kun.UserManager.Guardian.decode_and_verify(token) do
      {:ok, _} ->
        {:ok, socket}
      {:error, _} -> :error
    end
  end

  # This function will be called when there was no authentication information
  def connect(_params, _socket) do
    :error
  end

  defp process_auth_resp({:ok, user}, socket) do
    #Logger.warn "Found user:  #{inspect user}"
    {:ok, token, _} = Kun.UserManager.Guardian.encode_and_sign(user)
    # Logger.warn "Claims :  #{inspect claims}"
    {:ok, socket
          |> assign(:guardian_token, token)
          |> assign(:user_id, user.id)
          |> assign(:user, user )
    }
  end

  defp process_auth_resp({:error, reason}, socket) do
    {:ok, socket
          |> assign(:user_id, 0)
          |> assign(:login_error, reason)}
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
