import Config

config :rb, Repo,
  hostname: "db",
  database: "postgres",
  username: "postgres",
  password: "postgres",
  pool_size: 100

config :rb, ecto_repos: [Repo]

import_config "#{config_env()}.exs"

config :logger, level: :error
