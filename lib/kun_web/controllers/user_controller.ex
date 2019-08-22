defmodule KunWeb.UserController do
  use KunWeb, :controller

  alias Kun.UserManager
  alias Kun.UserManager.User
  alias Kun.UserManager.Guardian

  action_fallback(KunWeb.FallbackController)

  require Logger
  def create(conn, params) do
    with {:ok, %User{} = user} <- UserManager.create_user(params) do
      new_conn = Guardian.Plug.sign_in(conn, user)
      jwt = Guardian.Plug.current_token(new_conn)

      new_conn
      |> put_status(:created)
      |> render(KunWeb.SessionView, "show.json", user: user, jwt: jwt)
    end
  end
end
