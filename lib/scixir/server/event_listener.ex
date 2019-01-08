defmodule Scixir.Server.EventListener do
  use GenServer
  require Logger

  defstruct [
    :notification_key,
    :worker
  ]

  def start_link({args, options}) do
    GenServer.start_link(__MODULE__, args, options)
  end

  @impl true
  def init({notification_key, worker}) do
    Logger.info("Connecting to Redis")

    {:ok, %__MODULE__{notification_key: notification_key, worker: worker}, {:continue, :up}}
  end

  @impl true
  def handle_continue(:up, %__MODULE__{} = state) do
    loop(state.notification_key, state.worker)
  end

  defp loop(notification_key, worker) do
    with {:ok, data} <- Redix.command(Scixir.Redis, ["BLPOP", notification_key, 0], timeout: :infinity) do
      Scixir.Server.Handler.handle(data)
      loop(notification_key, worker)
    else
      _error ->
        Logger.error("An error occured")
        {:stop, "error", %__MODULE__{}}
    end
  end
end
