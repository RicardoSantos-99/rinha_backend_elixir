defmodule Rb.Queue do
  use GenServer
  alias Rb.DatabaseManager

  @spec start :: :ignore | {:error, any} | {:ok, pid}
  def start do
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  @spec enqueue(any) :: :ok
  def enqueue(user) do
    GenServer.cast(__MODULE__, {:enqueue, user})
  end

  @spec count :: any
  def count do
    GenServer.call(__MODULE__, :count)
  end

  # Server
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, %{users: []}}
  def init(:ok) do
    IO.inspect("START QUEUE")
    {:ok, %{users: [], count: 0}}
  end

  def handle_cast({:enqueue, user}, state) do
    state = Map.update(state, :users, [user], fn users -> [user | users] end)

    if length(state.users) > 100 do
      DatabaseManager.save(state.users)

      state =
        Map.update(state, :users, [], fn _ -> [] end)
        |> Map.update!(:count, fn count -> count + length(state.users) end)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_call(:count, _from, state) do
    {:reply, state.count, state}
  end
end
