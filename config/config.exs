use Mix.Config

config :scixir, :redis,
  url: "redis://localhost:6379",
  notification_key: "minio_events",
  worker: 5

config :logger, :console,
  format: "$dateT$time $metadata[$level] $levelpad$message\n"

config :ex_aws,
  access_key_id: "JV2ECX06XID7AG9FRDO1",
  secret_access_key: "0ny0EwDb39S9PJdaRhGuwKdW1H7TXFYapn8JJM71"

config :ex_aws, :s3,
  scheme: "http://",
  host: "127.0.0.1",
  port: "9000"
