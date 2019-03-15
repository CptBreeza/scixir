use Mix.Config

config :scixir, :redis,
  host: System.get_env("JET_REDIS_URL"),
  notification_key: System.get_env("MINIO_REDIS_NOTIFICATION_KEY"),
  worker: 5

config :ex_aws,
  access_key_id: System.get_env("JET_MINIO_ACCESS_KEY"),
  secret_access_key: System.get_env("JET_MINIO_SECRET_KEY")

config :ex_aws, :s3,
  scheme: "http://",
  host: System.get_env("JET_MINIO_HOST"),
  port: System.get_env("JET_MINIO_PORT")
