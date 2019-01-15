defmodule Scixir.Server.EventManager do
  use GenStage
  require Logger

  def start_link(:ok) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def receive_event(event) do
    GenStage.call(__MODULE__, {:event, event})
  end

  @impl true
  def init(:ok) do
    {:producer, {:queue.new, 0}}
  end

  @impl true
  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, incoming_demand + demand, [])
  end

  @impl true
  def handle_call({:event, event}, from, {queue, demand}) do
    Logger.debug "event received"

    dispatch_events(:queue.in({from, event}, queue), demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
         {item, queue} = :queue.out(queue),
         {:value, {from, event}} <- item
    do
      GenStage.reply(from, :ok)
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
