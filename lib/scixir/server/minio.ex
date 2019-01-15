defmodule Scixir.Server.Minio do
  alias Scixir.Event
  alias Scixir.Utilities.LoggingHelper

  use Scixir.Benchmark.ProgressDecorator

  @decorate progress
  def download_images(%Event{} = event, definition) do
    event =
      event
      |> Event.start_processing()
      |> LoggingHelper.log_event_start()

    Map.update!(event, :intermediate_storage, fn storage ->
      file_metadata = definition.analyze_event(event)
      file_path = definition.download(file_metadata)
      Map.put(storage, :in_file, %{file_metadata: file_metadata, file_path: file_path})
    end)
  end

  @decorate progress
  def resize_images(%Event{} = event, config) do
    Scixir.Engine.process(event, config)
  end

  @decorate progress
  def upload_images(%Event{} = event, definition) do
    Enum.each(
      event.intermediate_storage.out_files,
      &definition.upload(event.intermediate_storage.in_file.file_metadata, &1)
    )

    event
    |> Event.finish_processing()
    |> LoggingHelper.log_event_complete()
    |> definition.clean_local_storage()
  end
end
