use Mix.Config

config :logger, :console,
  format: "$dateT$time $metadata[$level] $levelpad$message\n"

import_config "#{Mix.env}.exs"
