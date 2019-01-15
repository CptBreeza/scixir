defmodule Scixir.Server.Main do
  @moduledoc false

  use GenServer

  alias Scixir.Server.Minio

  defstruct [
    :definition,
    :config
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([definition, config]) do
    {:ok, %__MODULE__{definition: definition, config: config}, {:continue, :up}}
  end

  def handle_continue(:up, %__MODULE__{definition: definition, config: config}) do
    [Scixir.Server.EventManager]
    |> Flow.from_stages()
    |> Flow.map(&Minio.download_orig_files(&1, definition))
    |> Flow.partition()
    |> Flow.reduce(fn -> [] end, fn event, _events ->
      Minio.process_and_upload(event, definition, config)
      []
    end)
    |> Enum.to_list()
  end
end
