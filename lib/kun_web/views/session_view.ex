defmodule KunWeb.SessionView do
  use KunWeb, :view

  def render("show.json", %{user: user, jwt: jwt}) do
    %{
      data: render_one(user, KunWeb.UserView, "user.json"),
      meta: %{token: jwt}
    }
  end

  def render("delete.json", _) do
    %{ok: true}
  end

  def render("error.json", %{error: error}) do
    %{errors: %{error: error}}
  end
end
