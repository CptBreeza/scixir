defmodule Scixir.Server.EventListener do
  use GenServer

  def start_link(notification_key) do
    GenServer.start_link(__MODULE__, notification_key, name: __MODULE__)
  end

  @impl true
  def init(notification_key) do
    {:ok, notification_key, {:continue, :up}}
  end

  @impl true
  def handle_continue(:up, notification_key) do
    receive_loop(notification_key)
  end

  defp receive_loop(notification_key) do
    with {:ok, data} <- Redix.command(Scixir.Redis, ["BLPOP", notification_key, 0], timeout: :infinity) do
      IO.puts "event received"
      Scixir.Server.EventManager.receive_event(data)
      receive_loop(notification_key)
    else
      _ -> {:stop, "error", notification_key}
    end
  end
end
