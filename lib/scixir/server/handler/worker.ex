defmodule Scixir.Server.Handler.Worker do
  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  @impl true
  def init(state) do
    IO.puts("Starting Worker")
    {:ok, state}
  end

  @impl true
  def handle_cast({:handle, data}, state) do
    Scixir.Handler.handle(data)
    {:noreply, state}
  end
end
