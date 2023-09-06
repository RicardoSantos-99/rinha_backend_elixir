import Config

config :rb, Repo,
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "postgres",
  username: "postgres",
  password: "postgres",
  pool_size: 100
