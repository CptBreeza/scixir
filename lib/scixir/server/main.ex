defmodule Scixir.Server.Main do
  @moduledoc """
  Main flow.

  1. Download images from OSS
  2. Resize images
  3. Upload resized versions of images to OSS
  """

  use Flow

  alias Scixir.Server.Minio

  def start_link(args) do
    args
    |> flow()
    |> Flow.start_link(name: __MODULE__)
  end

  def flow({definition, config}) do
    [Scixir.Server.EventManager]
    |> Flow.from_stages(min_demand: 6, max_demand: 40, stages: 1)
    |> Flow.map(&Minio.download_images(&1, definition))
    |> Flow.partition(min_demand: 4, max_demand: 8, stages: 4)
    |> Flow.map(&Minio.resize_images(&1, config))
    |> Flow.partition(min_demand: 1, max_demand: 8, stages: 1)
    |> Flow.each(&Minio.upload_images(&1, definition))
  end
end
