defmodule Scixir.Server.Handler.Worker do
  use GenServer
  require Logger

  def start_link(options) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  @impl true
  def init(state) do
    name =
      self()
      |> :erlang.process_info()
      |> Keyword.get(:registered_name)

    Logger.debug("Worker \"#{name}\" started")

    {:ok, state}
  end

  @impl true
  def handle_cast({:handle, data}, state) do
    Scixir.Engine.handle(data)
    {:noreply, state}
  end
end
