defmodule Rb.System do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init(
      [
        Rb.Apelidos,
        Rb.Queue,
        Rb.DatabaseManager,
        Rb.UsersCache
      ],
      strategy: :one_for_one
    )
  end
end
