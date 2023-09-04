defmodule Rb.Apelidos do
  use GenServer

  def start do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def save(apelido) do
    GenServer.cast(__MODULE__, {:key, apelido})
  end

  def get_apelidos do
    GenServer.call(__MODULE__, :get_apelidos)
  end

  def get(apelido) do
    GenServer.call(__MODULE__, {:member, apelido})
  end

  # Server
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    {:ok, MapSet.new()}
  end

  @impl true
  def handle_call(:get_apelidos, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:member, apelido}, _from, state) do
    {:reply, MapSet.member?(state, apelido), state}
  end

  @impl true
  def handle_cast({:key, apelido}, state) do
    if MapSet.member?(state, apelido) do
      {:noreply, state}
    else
      {:noreply, MapSet.put(state, apelido)}
    end
  end
end
