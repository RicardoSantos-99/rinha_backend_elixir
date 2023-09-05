defmodule Rb.UsersCache do
  use GenServer

  def start_link(_opts) do
    Process.sleep(Enum.random(1..5))

    case GenServer.whereis({:global, __MODULE__}) do
      nil ->
        GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

      _pid ->
        :ignore
    end
  end

  def get(id) do
    GenServer.call({:global, __MODULE__}, {:get, id})
  end

  def insert(user) do
    GenServer.call({:global, __MODULE__}, {:put, user})
  end

  def init(_arg) do
    {:ok, %{}}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def handle_call({:put, user}, _from, state) do
    {:reply, :ok, Map.put(state, user["id"], user)}
  end
end
