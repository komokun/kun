defmodule KunWeb.RailChannel do
  use KunWeb, :channel

  require Logger

  def join("rail:" <> rail_id, _params, socket) do
    #send(self(), :after_join)
    {
      :ok,
      %{},
      assign(socket, :rail_id, rail_id)
    }
  end


end
