defmodule Scixir.Server.Minio.PreProcessor do
  use GenStage

  alias Scixir.Event
  alias Scixir.Utilities.LoggingHelper

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init({definition, demands}) do
    options =
      [
        max_demand: demands.max_demand,
        min_demand: demands.min_demand
      ]

    {:producer_consumer, definition, subscribe_to: [{Scixir.Server.EventManager, options}]}
  end

  @impl true
  def handle_events(events, _from, definition) do
    events =
      Enum.map(events, fn event ->
        event =
          event
          |> Event.start_processing()
          |> LoggingHelper.log_event_start()

        Map.update!(event, :intermediate_storage, fn storage ->
          file_metadata = definition.analyze_event(event)
          file_path = definition.download(file_metadata)
          Map.put(storage, :in_file, %{file_metadata: file_metadata, file_path: file_path})
        end)
      end)

    {:noreply, events, definition}
  end
end
