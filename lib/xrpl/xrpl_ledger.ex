defmodule XRPL.Ledger do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    #Phoenix.PubSub.subscribe(:xrpl, "server_info")
    {:ok, %{}}
  end

  def init_ledger_transaction(pid, payload, socket) do
    # Pass broadcast socket to Ledger process obtained from poolboy
    :gen_server.call(pid, {:transaction, socket, payload})
    # Start a call to Ledger connection socket client
  end

  def handle_call({:transaction, socket, payload}, _from, state) do

    #Logger.warn("Subscribing!")
    #Logger.warn("State in handle info  #{inspect state}")
    Phoenix.PubSub.subscribe(:xrpl, "server_info")

    new_state = Map.put_new(state, "socket", socket)
    #Logger.warn("New State in handle info  #{inspect new_state}")

    :poolboy.transaction(:xrpl_connection_pool,
        fn(pid) -> send_to_xrpl(pid, payload) end)

    {:noreply,  new_state}
  end

  def handle_info({:response, msg}, state) do
    #Logger.warn("Pubsub from #{inspect self()} message #{msg} ")
    #Logger.warn("Socket to send response to  #{inspect state.socket}")
    Phoenix.Channel.broadcast_from(state["socket"], "ledger", %{ "data" => msg })
    {:noreply, state}
  end

  def server_info() do
    :poolboy.transaction(:xrpl_connection_pool,
        fn(pid) -> send_to_xrpl(pid, %{"id" => 1, "command" => "server_info"}) end)
    Logger.info("Finishing... Server Info")
  end

  defp send_to_xrpl(pid, command) do
    #Logger.warn("Inside send_to_xrpl")
    message = Poison.encode!(command)
    pid
    |> send_message(message)
  end

  @spec send_message(pid, String.t) :: :ok
  def send_message(pid, message) do
    #Logger.warn("Sending message: #{inspect message} to #{inspect pid}")
    WebSockex.send_frame(pid, {:text, message})
  end

end
