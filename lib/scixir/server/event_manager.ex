defmodule Scixir.Server.EventManager do
  @moduledoc """
  Store and buff events pushed by EventListener. Serve as
  the event source of processing flow.
  """

  use GenStage
  require Logger

  def start_link(:ok) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  def receive_event(event) do
    GenStage.cast(__MODULE__, {:push, event})
  end

  def queue_size(name) do
    GenStage.call(name, :queue_size)
  end

  def handle_call(:queue_size, _from, {queue, _demand} = state) do
    {:reply, :queue.len(queue), [], state}
  end

  def handle_cast({:push, event}, {queue, demand}) do
    Logger.info("Event #{event.uuid} received")
    dispatch_events(:queue.in(event, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) when incoming_demand > 0 do
    dispatch_events(queue, demand + incoming_demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with true <- demand > 0,
         {item, remaining_queue} <- :queue.out(queue),
         {:value, event} <- item
    do
      dispatch_events(remaining_queue, demand - 1, [event | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
