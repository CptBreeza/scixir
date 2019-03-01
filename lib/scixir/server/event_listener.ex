defmodule Scixir.Server.EventListener do
  @moduledoc """
  Listen to Redis for events published by Minio, and reject events that is generated
  by Scixir's action. Events are decoded and pushed to EventManager as soon as it was
  received.
  """

  use GenServer
  require Logger

  alias Scixir.Event

  def start_link(notification_key) do
    GenServer.start_link(__MODULE__, notification_key, name: __MODULE__)
  end

  @impl true
  def init(notification_key) do
    Logger.info("Start listening to Redis##{notification_key}")
    {:ok, notification_key, {:continue, :up}}
  end

  @impl true
  def handle_continue(:up, notification_key) do
    receive_loop(notification_key)
  end

  defp receive_loop(notification_key) do
    with {:ok, data} <- Redix.command(Scixir.Redis, ["BLPOP", notification_key, 0], timeout: :infinity) do
      event = Event.from_minio(data)
      unless Event.scixir_generated?(event) do
        Scixir.Server.EventManager.receive_event(event)
      end
      receive_loop(notification_key)
    else
      _ -> {:stop, "error", notification_key}
    end
  end
end
