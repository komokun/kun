defmodule XRPL.Client do
  use WebSockex
  require Logger

  def start_link(state) do
    {:ok, pid } = WebSockex.start_link("wss://s2.ripple.com:443", __MODULE__, state)
    Logger.info("Newly created PID: #{inspect pid}")
    #:sys.trace pid, true
    {:ok, pid }
  end

  def set_broadcast(server, topic) do
    Logger.info("I am #{inspect server} and #{inspect topic} is my caller.")
  end

  def handle_frame({:text, msg}, state) do
    #Logger.warn("Received Message: #{inspect msg}")
    Phoenix.PubSub.broadcast(:xrpl, "server_info", {:response, msg})
    {:ok, state}
  end

end

defmodule XRPL.Connection do
  use Supervisor
  require Logger

  @xrpl_connection_pool :xrpl_connection_pool
  @xrp_ledger_pool :xrp_ledger_pool

  def start_link(opts \\ []) do
    Logger.info "Starting ledger connections supervisor"
    Supervisor.start_link __MODULE__, [], opts
  end


  def init([]) do
    connection_opts = [
      name: {:local, @xrpl_connection_pool},
      worker_module: XRPL.Client,
      size: 2,
      max_overflow: 0,
      strategy: :fifo
    ]

    ledger_opts = [
      name: {:local, @xrp_ledger_pool},
      worker_module: XRPL.Ledger,
      size: 2,
      max_overflow: 0,
      strategy: :fifo
    ]

    Logger.info "Making Connections!"

    children = [
        :poolboy.child_spec(@xrpl_connection_pool, connection_opts),
        :poolboy.child_spec(@xrp_ledger_pool, ledger_opts, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
