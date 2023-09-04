defmodule Rb.Database do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, pid} =
      Postgrex.start_link(
        # db
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "postgres"
      )

    {:ok, pid}
  end

  def query(sql, params) do
    GenServer.call(__MODULE__, {:query, sql, params})
  end

  def handle_call({:query, sql, params}, _from, pid) do
    result = Postgrex.query(pid, sql, params)
    {:reply, result, pid}
  end
end
