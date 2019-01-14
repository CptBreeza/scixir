defmodule Scixir.Server.Minio.Processor do
  use GenStage

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init({config, demands}) do
    options =
      [
        max_demand: demands.max_demand,
        min_demand: demands.min_demand
      ]

    {:producer_consumer, config, subscribe_to: [{Scixir.Server.Minio.PreProcessor, options}]}
  end

  @impl true
  def handle_events(events, _from, config) do
    {:noreply, Enum.map(events, &Scixir.Engine.process(&1, config)), config}
  end
end
