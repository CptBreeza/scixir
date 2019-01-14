defmodule Scixir.Server.Minio.PostProcessor do
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

    {:consumer, definition, subscribe_to: [{Scixir.Server.Minio.Processor, options}]}
  end

  @impl true
  def handle_events(events, _from, definition) do
    Enum.each(events, fn event ->
      Enum.each(
        event.intermediate_storage.out_files,
        &definition.upload(event.intermediate_storage.in_file.file_metadata, &1)
      )

      event
      |> Event.finish_processing()
      |> LoggingHelper.log_event_complete()
      |> definition.clean_local_storage()
    end)

    {:noreply, [], definition}
  end
end
