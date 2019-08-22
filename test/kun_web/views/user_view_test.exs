defmodule KunWeb.UserViewTest do
  use KunWeb.ConnCase, async: true

  alias Kun.UserManager
  alias KunWeb.UserView

  @user_params %{name: "some name", email: "some@email", password: "some password"}

  test "index.json" do
    {:ok, user} = UserManager.create_user(@user_params)

    assert UserView.render("user.json", %{user: user}) == %{
             id: user.id,
             name: user.name,
             email: user.email
           }
  end
end
