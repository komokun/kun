defmodule KunserverWeb.RoomChannelTest do
  # Elixir warns about a bunch of unused variables even though they are used
  @compile :nowarn_unused_vars
  require Logger
  use KunWeb.ChannelCase

  alias KunWeb.UserSocket

  alias Kun.UserManager


  @create_attrs %{name: "some name", email: "some@email", password: "some password"}

  setup do

    user = create_user("")
    {:ok, token, full_claims} = Kun.UserManager.Guardian.encode_and_sign(user)

    {:ok, socket} = connect(UserSocket, %{"token" => token})

    {:ok, %{user: user, socket: socket}}
  end



  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@create_attrs)
    user
  end

end
