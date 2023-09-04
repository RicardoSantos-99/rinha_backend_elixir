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

    # Ver ser vale a pena usar o flow
    Task.async_stream(
      users,
      fn user ->
        SQL.query(Repo, sql, [
          Map.get(user, "id"),
          Map.get(user, "nome"),
          Map.get(user, "apelido"),
          Map.get(user, "nascimento"),
          Map.get(user, "stack")
        ])
      end,
      ordered: false,
      max_concurrency: 20
    )
    |> Enum.to_list()

    {:noreply, state}
  end
end
