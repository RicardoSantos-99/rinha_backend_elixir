import Config

config :rb, Repo,
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "postgres",
  username: "postgres",
  password: "postgres",
  pool_size: 15

System.put_env("HTTP_SERVER_PORT", "4000")
