defmodule XRPL.PubSub do
  use Supervisor
  require Logger

  def start_link(opts \\ []) do
    Logger.info "Starting XRPL pub sub"
    Supervisor.start_link __MODULE__, [], opts
  end

  def init([]) do
    children = [
      %{
          id: Phoenix.PubSub.PG2,
          start: { Phoenix.PubSub.PG2, :start_link, [:xrpl, [
              pool_size: 1,
              node_name: "name"
          ]]}
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
