use Mix.Config

config :scixir, :redis,
  url: System.get_env("REDIS_HOST"),
  notification_key: System.get_env("MINIO_NOTIFICATION_KEY"),
  worker: System.get_env("REDIS_LISTENER_WORKER")

config :ex_aws,
  access_key_id: System.get_env("MINIO_ACCESS_KEY"),
  secret_access_key: System.get_env("MINIO_SECRET_ACCESS_KEY")

config :ex_aws, :s3,
  scheme: "http://",
  host: System.get_env("MINIO_HOST"),
  port: System.get_env("MINIO_PORT")
