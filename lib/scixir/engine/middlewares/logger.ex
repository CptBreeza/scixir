defmodule Scixir.Engine.Middlewares.Logger do
  @behaviour Scixir.Engine.Middleware

  require Logger

  @impl true
  def before_handle(%{data: data, metadata: metadata} = payload) do
    worker_name =
      self()
      |> :erlang.process_info()
      |> Keyword.get(:registered_name)

    Logger.debug("Object #{data.s3.object.eTag} being received and processed by #{worker_name}")

    %{payload | metadata: Map.put(metadata, :start_processing_at, NaiveDateTime.utc_now())}
  end

  @impl true
  def after_handle(%{data: data, metadata: metadata} = payload) do
    Logger.debug("Object #{data.s3.object.eTag} processing complete, costed #{NaiveDateTime.diff(NaiveDateTime.utc_now(), metadata.start_processing_at)}ms")

    payload
  end
end
