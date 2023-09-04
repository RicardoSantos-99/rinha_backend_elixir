defmodule Repo do
  use Ecto.Repo,
    otp_app: :rb,
    adapter: Ecto.Adapters.Postgres
end
