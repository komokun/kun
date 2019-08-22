defmodule XRPL.Ledger do
  use GenServer
  require Logger

  def start_link(_) do

    #initial = Map.put(%{}, "socket", "")

    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(args) do

    {:ok, args}
  end
  def server_info() do
    :poolboy.transaction(:xrpl_connection_pool,
        fn(pid) -> send_to(pid) end)
    Logger.info("Finishing... Server Info")
  end

  def make_server_call(payload) do
    :poolboy.transaction(:xrpl_connection_pool,
        fn(pid) -> send_message(pid, payload) end)
    Logger.info("Finishing... Server Info")
  end

  def send_to(pid) do

    message = Poison.encode!(%{"id" => 1, "command" => "server_info"})
    pid
    |> send_message(message)
  end

  def init_ledger_transaction(pid, payload, socket) do
    # Pass broadcast socket to Ledger process obtained from poolboy
    :gen_server.call(pid, {:transaction, socket})
    # Start a call to Ledger connection socket client
    make_server_call(payload)
  end

  def handle_info({:transaction, socket}, state) do

    Logger.warn("Subscribing!")
    Logger.warn("State in handle info  #{inspect state}")
    Phoenix.PubSub.subscribe(:xrpl, "server_info")

    new_state = Map.put_new(state, "socket", socket)
    Logger.warn("New State in handle info  #{inspect new_state}")
    {:noreply,  new_state}
  end

  def handle_info({:response, msg}, state) do
    Logger.info("Pubsub message #{state.socket} ")
    Phoenix.Channel.broadcast!(state.socket, "ledger", %{ body: msg })
    {:noreply, state}
  end

  @spec send_message(pid, String.t) :: :ok
  def send_message(pid, message) do
    Logger.info("Sending message: #{inspect message} to #{inspect pid}")
    WebSockex.send_frame(pid, {:text, message})
  end

end
