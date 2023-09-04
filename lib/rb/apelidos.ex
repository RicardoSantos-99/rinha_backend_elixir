defmodule Rb.Apelidos do
  @moduledoc """
   atualmente está mantendo a lista de apelidos em um MapSet compartilhado por todos os nodes
   o que implica que terá uma lista de nomes em cada node

   n1 - ["apelido1", "apelido2", "apelido3"]
   n2 - ["apelido1", "apelido2", "apelido3"]

   - uso de memoria dobrado por manter a mesma lista em cada node
   - se o node cair ainda mantém a lista no outra
   - quantidade de operações dobradas (para manter as listas sincronizada)

   considerar criar uma lista diferente de nomes em cada node
   usando uma fn de hash para mandar sempre o mesmo apelido para o mesmo node
   e assim manter uma lista de nomes diferentes em cada node

   - menos memoria usada por node
   - o que fazer se o node cair?
   - cada node consegue inserir um novo apelido em paralelo na sua lista
   - toda vez que buscar um apelido que não estiver na lista do node atual ele vai buscar na lista do outro node

   n1 - ["apelido1", "apelido2", "apelido3"]
   n2 - ["apelido4", "apelido5", "apelido6"]

  """
  use GenServer

  @spec start :: GenServer.on_start()
  def start do
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  @spec save(String.t()) :: :ok
  def save(apelido) do
    GenServer.cast({:global, __MODULE__}, {:key, apelido})
  end

  @spec list :: MapSet.t()
  def list do
    GenServer.call({:global, __MODULE__}, :list)
  end

  @spec get(String.t()) :: boolean()
  def get(apelido) do
    GenServer.call({:global, __MODULE__}, {:member, apelido})
  end

  # Server

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    case GenServer.whereis({:global, __MODULE__}) do
      nil ->
        GenServer.start_link(__MODULE__, opts, name: {:global, __MODULE__})

      _pid ->
        :ignore
    end
  end

  @impl true
  @spec init(any) :: {:ok, MapSet.t()}
  def init(_init_arg) do
    {:ok, MapSet.new()}
  end

  @impl true
  def handle_call(:list, _from, state) do
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
