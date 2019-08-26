defmodule KunserverWeb.AuthorizedChannelTest do
  use KunWeb.ChannelCase
  alias KunWeb.UserSocket

  alias Kun.UserManager

  require Logger

  setup do

    user = create_user("")
    {:ok, token, full_claims} = Kun.UserManager.Guardian.encode_and_sign(user)

    {:ok, socket} = connect(UserSocket, %{"token" => token})

    {:ok, _reply, socket} = subscribe_and_join(socket,
      KunWeb.AuthorizedChannel,
      "authorized:" <> Integer.to_string(user.id),
      %{})

    {:ok, %{user: user, socket: socket, token: token}}
  end

  #This test is misplaced. Should be at UserSocketTest
  test "Check authorized_id assignment to the socket after join", %{socket: socket, user: user} do

    assert socket.assigns.authorized_id == Integer.to_string(user.id)
  end

  test "pong replies with status ok", %{socket: socket} do
    ref = push socket, "pong", %{"hello" => "there"}
    assert_reply ref, :ok, %{message: "pong"}
  end

  @create_attrs %{name: "some name", email: "some@email", password: "some password"}
  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end


end
