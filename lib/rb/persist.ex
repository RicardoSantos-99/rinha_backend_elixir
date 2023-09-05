defmodule Rb.Persist do
  use GenServer
  alias Ecto.Adapters.SQL

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:ok, []}
  end

  def save(users) do
    GenServer.cast(__MODULE__, {:save, users})
  end

  def handle_cast({:save, users}, state) do
    sql = """
    INSERT INTO users (id, nome, apelido, nascimento, stack)
    VALUES ($1, $2, $3, $4, $5)
    """

    Task.async_stream(
      users,
      fn user ->
        SQL.query(Repo, sql, [
          Map.get(user, "id"),
          Map.get(user, "nome"),
          Map.get(user, "apelido"),
          Map.get(user, "nascimento"),
          transform_to_text(Map.get(user, "stack"))
        ])
      end,
      ordered: false,
      max_concurrency: 100
    )
    |> Enum.to_list()

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    IO.inspect("ERROR")
    IO.puts("GenServer crashed because of #{inspect(reason)}", label: "ERRO")
    {:noreply, state}
  end

  def terminate(reason, _state) do
    IO.inspect(reason, label: "ERRO")
  end

  defp transform_to_text(nil), do: ""
  defp transform_to_text(list), do: Enum.join(list, " ")
end
