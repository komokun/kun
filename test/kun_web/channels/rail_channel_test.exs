defmodule KunWeb.RailChannelTest do
  use KunWeb.ChannelCase
  alias KunWeb.UserSocket

  alias Kun.UserManager

  require Logger

  setup do

    user = create_user("")
    {:ok, socket} = connect(UserSocket, %{"email" => user.email, "password" => "password"})

    {:ok, _reply, socket} = subscribe_and_join(
      socket,
      KunWeb.RailChannel,
      "login:"<> Integer.to_string(user.id),
      %{"name" => user.name})

    ## to make sure we receive the :after_join with jwt token
    token = socket.assigns[:guardian_default_token]
    Logger.info "Dump token: #{inspect token} ---------> #{inspect user}"
    assert_push "user:guardian_token", %{guardian_token: token}
    {:ok, socket: socket, user: user, token: token }
  end

  @create_attrs %{name: "some name", email: "some@email", password: "password"}
  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end
end
