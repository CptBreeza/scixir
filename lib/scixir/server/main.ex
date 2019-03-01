defmodule Scixir.Server.Main do
  @moduledoc false

  use Flow
  require Logger

  alias Scixir.Server.Minio

  defstruct [
    :definition,
    :config
  ]

  def start_link(args) do
    pipeline = flow(args)
    Flow.start_link(pipeline, name: __MODULE__)
  end

  # def init([definition, config]) do
  #   {:ok, %__MODULE__{definition: definition, config: config}, {:continue, :up}}
  # end

  # def handle_continue(:up, %__MODULE__{definition: definition, config: config}) do
  def flow([definition, config]) do
    [Scixir.Server.EventManager]
    |> Flow.from_stages(min_demand: 6, max_demand: 40, stages: 1)
    |> Flow.map(&Minio.download_images(&1, definition))
    |> Flow.partition(min_demand: 4, max_demand: 8, stages: 4)
    |> Flow.map(&Minio.resize_images(&1, config))
    |> Flow.partition(min_demand: 1, max_demand: 8, stages: 1)
    |> Flow.each(&Minio.upload_images(&1, definition))
    # |> Enum.to_list()
  end
end
