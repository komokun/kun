defmodule KunWeb.LoginChannelTest do
  use KunWeb.ChannelCase #,async: true
  alias KunWeb.UserSocket
  alias KunWeb.LoginChannel

  alias Kun.UserManager
  require Logger


  setup do

    user = create_user("")
#    Logger.info "Dump role: #{inspect role} ---------> #{inspect user}"
    {:ok, socket} = connect(UserSocket,
      %{"email" => user.email,
	      "password" => "password"}
    )
    {:ok, _reply, socket} = subscribe_and_join(
      socket,
      LoginChannel,
      "login:"<> Integer.to_string(user.id),
      %{"name" => user.name}
    )

    ## to make sure we receive the :after_join with jwt token
    token = socket.assigns[:guardian_default_token]
    Logger.info "Dump token: #{inspect token} ---------> #{inspect user}"
    assert_push "user:guardian_token", %{guardian_token: token}
    {:ok, socket: socket, user: user, token: token }
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{message: "pong"}
  end

  test "logout ", %{socket: socket, token: token} do
    #Process.unlink(socket.channel_pid)
    #Logger.warn("#{inspect token}")
    push socket, "logout", %{ "guardian_token" => token }
    #assert_received(:exit)
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  @create_attrs %{name: "some name", email: "some@email", password: "password"}
  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end

end

