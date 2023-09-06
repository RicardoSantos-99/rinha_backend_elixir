defmodule Rb.DatabaseManager do
  alias Rb.Worker
  @pool_size 3

  def child_spec(_opts) do
    :poolboy.child_spec(
      __MODULE__,
      name: {:local, __MODULE__},
      worker_module: Rb.Worker,
      size: @pool_size
    )
  end

  def save(users) do
    :poolboy.transaction(__MODULE__, fn pid ->
      Worker.save(pid, users)
    end)
  end
end
