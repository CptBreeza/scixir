defmodule Scixir.Utilities.LoggingHelper do
  require Logger

  def log_event_start(%{uuid: event_uuid} = event) do
    Logger.debug("Event #{event_uuid} processing started")
    event
  end

  def log_event_complete(%{uuid: event_uuid, metrics: %{processing_time: processing_time}} = event) do
    Logger.debug("Event #{event_uuid} processing completed in #{processing_time * 1000}ms")
    event
  end
end
