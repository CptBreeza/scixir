use Mix.Config

config :scixir, :redis,
  url: "redis://localhost:6379",
  notification_key: "minio_events",
  worker: 5
