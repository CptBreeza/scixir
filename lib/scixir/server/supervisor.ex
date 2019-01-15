defmodule Scixir.Server.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Logger.info("Initializing server")

    %{url: url, notification_key: notification_key} = Map.new(Application.get_env(:scixir, :redis))

    definition = Scixir.Engine.Minio.Definition
    config =
      %{
        versions:
          %{
            "large" => "1000x1000",
            "medium" => "500x500",
            "small" => "300x300"
          }
      }

    progress_scopes = ~w{download_images resize_images upload_images}a

    children = [
      {Scixir.Benchmark.Progress, progress_scopes},
      {Redix, {url, [name: Scixir.Redis]}},
      {Scixir.Server.EventManager, :ok},
      {Scixir.Server.EventListener, notification_key},
      {Scixir.Server.Main, [definition, config]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
