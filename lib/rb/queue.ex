defmodule Rb.Queue do
  use GenServer

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
    {:ok, %{users: []}}
  end

  def handle_cast({:enqueue, user}, state) do
    state = Map.update(state, :users, [user], fn users -> [user | users] end)

    if length(state.users) > 10 do
      Rb.Persist.save(state.users)

      state = Map.update(state, :users, [], fn _ -> [] end)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_call(:count, _from, state) do
    {:reply, 10, state}
  end
end
