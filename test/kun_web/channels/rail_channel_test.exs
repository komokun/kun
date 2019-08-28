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
      "rail:"<> Integer.to_string(user.id),
      %{"name" => user.name})

    token = socket.assigns[:guardian_default_token]
    {:ok, socket: socket, user: user, token: token }
  end

  test "pong replies with status ok", %{socket: socket} do
    ref = push socket, "pong", %{"hello" => "there"}
    assert_reply ref, :ok, %{message: "pong"}
  end

  test "Check rail_id assignment to the socket after join", %{socket: socket, user: user} do

    assert socket.assigns.rail_id == Integer.to_string(user.id)
  end

  test ":xrpl test ripple server info", %{socket: socket} do
    ref = push socket, :xrpl, %{"id" => 1, "command" => "server_info"}

    assert_broadcast "ledger", %{"data" => _}, 1000
  end

  @create_attrs %{name: "some name", email: "some@email", password: "password"}
  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end
end
