defmodule Kun.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Kun.Repo, []),
      # Start the endpoint when the application starts
      supervisor(KunWeb.Endpoint, []),
      # Start your own worker by calling: Prater.Worker.start_link(arg1, arg2, arg3)
      # worker(Prater.Worker, [arg1, arg2, arg3]),
      #supervisor(KuniserverWeb.Presence, []),

      supervisor(XRPL.PubSub, []),
      supervisor(XRPL.Connection, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kun.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KunWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
