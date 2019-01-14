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
    demands =
      %{
        max_demand: 5,
        min_demand: 1
      }
    config =
      %{
        versions:
          %{
            "large" => "1000x1000",
            "medium" => "500x500",
            "small" => "300x300"
          }
      }

    children = [
      {Redix, {url, [name: Scixir.Redis]}},
      Scixir.Server.EventManager,
      {Scixir.Server.EventListener, notification_key},
      {Scixir.Server.Minio.PreProcessor, {definition, demands}},
      {Scixir.Server.Minio.Processor, {config, demands}},
      {Scixir.Server.Minio.PostProcessor, {definition, demands}},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
