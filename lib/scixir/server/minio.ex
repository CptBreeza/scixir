defmodule Scixir.Server.Minio do
  alias Scixir.Event
  alias Scixir.Utilities.LoggingHelper

  def download_orig_files(%Event{} = event, definition) do
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

  def process_and_upload(%Event{} = event, definition, config) do
    event = Scixir.Engine.process(event, config)

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
