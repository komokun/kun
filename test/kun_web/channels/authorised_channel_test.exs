defmodule KunserverWeb.AuthorizedChannelTest do
  # Elixir warns about a bunch of unused variables even though they are used
  @compile :nowarn_unused_vars
  require Logger
  use KunWeb.ChannelCase

  alias KunWeb.UserSocket

  alias Kun.UserManager
  alias Kun.UserManager.Guardian

  @create_attrs %{name: "some name", email: "some@email", password: "some password"}

  setup do

    user = create_user("")
    {:ok, token, full_claims} = Guardian.encode_and_sign(user)

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

  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end


end