defmodule Scixir.Event do
  defstruct [
    :uuid,
    :data,
    errors: [],
    metrics: %{},
    intermediate_storage: %{}
  ]

  def from_minio([_notification_key, raw_data]) when is_binary(raw_data) do
    [_timestamp, [data]] = Jason.decode!(raw_data, keys: :atoms)

    %__MODULE__{
      uuid: UUID.uuid4(),
      data: data
    }
  end

  def start_processing(%__MODULE__{metrics: metrics} = event) do
    %{event |
      metrics: Map.put(metrics, :started_processing_at, NaiveDateTime.utc_now())
    }
  end

  def finish_processing(%__MODULE__{metrics: metrics} = event) do
    now = NaiveDateTime.utc_now()
    processing_time = NaiveDateTime.diff(now, metrics.started_processing_at)

    %{event |
      metrics: Map.merge(metrics, %{finish_processing_at: now, processing_time: processing_time})
    }
  end

  def scixir_generated?(%__MODULE__{data: data}) do
    "true" == get_in(data, [:s3, :object, :userMetadata, :"X-Amz-Meta-Scixir_generated"])
  end
end
