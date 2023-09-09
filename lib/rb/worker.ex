defmodule Rb.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_) do
    {:ok, %{}}
  end

  def save(pid, users) do
    GenServer.cast(pid, {:save, users})
  end

  def handle_cast({:save, users}, state) do
    entries =
      Enum.map(users, fn entry ->
        Map.update!(entry, :stack, fn stack -> transform_to_text(stack) end)
      end)

    Repo.insert_all("users", entries)

    {:noreply, state}
  end

  defp transform_to_text(nil), do: ""
  defp transform_to_text(list), do: Enum.join(list, " ")
end
