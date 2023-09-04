defmodule Rb.TableHash do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def save_name(name) do
    GenServer.cast(__MODULE__, {:key, name})
  end

  def get_names do
    GenServer.call(__MODULE__, :get_names)
  end

  def get_name(name) do
    GenServer.call(__MODULE__, {:get_name, name})
  end

  # Server
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:get_names, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get_name, name}, _from, state) do
    key = :erlang.phash2(name, 50000)

    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_cast({:key, name}, state) do
    key = :erlang.phash2(name, 50000)

    elements = Map.get(state, key)

    state =
      if is_nil(elements) do
        Map.put(state, key, [name])
      else
        if Enum.member?(elements, name) do
          state
        else
          Map.put(state, key, [name | elements])
        end
      end

    {:noreply, state}
  end
end
