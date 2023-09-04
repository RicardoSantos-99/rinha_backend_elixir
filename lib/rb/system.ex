defmodule Rb.System do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    IO.inspect("Starting Rb.System")

    Supervisor.init(
      [
        Rb.Database,
        Rb.Apelidos,
        Rb.Queue
      ],
      strategy: :one_for_one
    )
  end
end
