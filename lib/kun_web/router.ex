defmodule KunWeb.Router do
  use KunWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Kun.UserManager.Pipeline
  end


  scope "/api", KunWeb do
    pipe_through(:api)

    post("/sessions", SessionController, :create)
    post("/users", UserController, :create)
  end

  scope "/api", KunWeb do
    pipe_through([:api, :api_auth])

    delete("/sessions", SessionController, :delete)
    post("/sessions/refresh", SessionController, :refresh)
  end


end
