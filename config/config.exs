use Mix.Config

config :logger, :console,
  format: "$dateT$time $metadata[$level] $levelpad$message\n"

config :scixir, :versions,
  %{
    "large" => "1000x1000",
    "medium" => "500x500",
    "small" => "300x300"
  }

import_config "#{Mix.env}.exs"
