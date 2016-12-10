defmodule Scoreboard.Server do
  @moduledoc """
  Process that manages the scoreboard ets tables for the current node.
  """
  use GenServer
  alias Scoreboard.Partition

  defmodule State do
    @moduledoc false
    defstruct [
      scoreboard: nil,
      partitions: [],
      role: nil
    ]
  end

  @doc """
  Starts a node manager process.
  """
  @spec start_link(Scoreboard.t, Scoreboard.role, [{non_neg_integer, Partition.t}]) :: GenServer.on_start
  def start_link(scoreboard, role, partition_indices) do
    GenServer.start_link(__MODULE__, [scoreboard, role, partition_indices], [name: scoreboard])
  end

  @doc """
  Looks up the integer value for a given key.
  """
  @spec lookup(Scoreboard.t, Scoreboard.key) :: {:ok, integer} | {:error, :not_found}
  def lookup(scoreboard, key) do
    partition_for(scoreboard, key)
    |> Partition.lookup(key)
  end

  @doc """
  Inserts a new counter for the given key, if it does not already exist.
  """
  @spec put_new(Scoreboard.t, Scoreboard.key, integer) ::
    {:ok, integer} |
    {:error, :already_exists} |
    :buffered
  def put_new(scoreboard, key, initial_value \\ 0) do
    partition_for(scoreboard, key)
    |> Partition.put_new(key, initial_value)
  end

  @doc """
  Updates the score for a key by the given increment.
  """
  @spec update(Scoreboard.t, Scoreboard.key, Scoreboard.vote) ::
    {:ok, integer} |
    {:error, :not_found} |
    :buffered
  def update(scoreboard, key, inc) when inc == 1 or inc == -1 do
    partition_for(scoreboard, key)
    |> Partition.update(key, inc)
  end

  @doc """
  Overwrites the score for a key with the given value
  """
  @spec set(Scoreboard.t, Scoreboard.key, integer) ::
    {:ok, integer} |
    {:error, :not_found} |
    :buffered
  def set(scoreboard, key, value) do
    partition_for(scoreboard, key)
    |> Partition.set(key, value)
  end

  @doc """
  Locks an entire scoreboard, buffering writes for when it is unlocked.
  """
  @spec lock(Scoreboard.t) :: :ok
  def lock(scoreboard) do
    GenServer.call(scoreboard, :lock)
  end

  @doc """
  Unlocks an entire scoreboard, executing any buffered writes.
  """
  @spec unlock(Scoreboard.t) :: :ok
  def unlock(scoreboard) do
    GenServer.call(scoreboard, :unlock)
  end

  @doc false
  def init([scoreboard, role, partition_indices]) do
    num_partitions = length(partition_indices)
    init_scoreboard_table(scoreboard, num_partitions, partition_indices)
    partition_names = Enum.map(partition_indices, &elem(&1, 1))
    maybe_monitor_nodes(role)
    maybe_send_announce(role)
    state = struct(State, [scoreboard: scoreboard, partitions: partition_names, role: role])
    {:ok, state}
  end

  @doc false
  def handle_call({:master, node}, _from, %{role: {:slave, _nil}} = state) do
    role = {:slave, node}
    unlock_all(state.partitions)
    {:reply, :ok, %{state| role: role}}
  end
  def handle_call({:master, _}, _from, state) do
    {:reply, :ok, state}
  end
  def handle_call(:lock, _from, state) do
    lock_all(state.partitions)
    {:reply, :ok, state}
  end
  def handle_call(:unlock, _from, state) do
    unlock_all(state.partitions)
    {:reply, :ok, state}
  end

  @doc false
  def handle_info(:announce, state) do
    me = node()
    slaves = Node.list()
    with {replies, []} <- GenServer.multi_call(slaves, state.scoreboard, {:master, me}),
         [] <- Enum.reject(replies, fn {_node, reply} -> reply === :ok end)
    do
      unlock_all(state.partitions)
      {:noreply, state}
    else
      {_replies, bad_nodes} -> {:stop, {:bad_nodes, bad_nodes}, state}
      bad_replies -> {:stop, {:bad_replies, bad_replies}, state}
    end
  end
  def handle_info({:nodeup, node}, state) do
    IO.puts "Nodeup #{node}"
    {:noreply, state}
  end
  def handle_info({:nodedown, node}, state) do
    IO.puts "Nodedown #{node}"
    {:noreply, state}
  end

  defp partition_for(scoreboard, key) do
    partitions = :ets.lookup_element(scoreboard, scoreboard, 2)
    hash = :erlang.phash2(key, partitions)
    :ets.lookup_element(scoreboard, hash, 2)
  end

  defp init_scoreboard_table(name, num_partitions, partition_indices) do
    name = :ets.new(name, [:named_table, {:read_concurrency, true}])
    true = :ets.insert(name, {name, num_partitions})
    true = :ets.insert(name, partition_indices)
  end

  defp maybe_monitor_nodes(:local), do: :ok
  defp maybe_monitor_nodes(_) do
    :net_kernel.monitor_nodes(true)
  end

  defp maybe_send_announce({:master, _}) do
    send(self(), :announce)
  end
  defp maybe_send_announce(_), do: :ok

  defp unlock_all(partitions) do
    Enum.each(partitions, &Partition.unlock(&1))
  end

  defp lock_all(partitions) do
    Enum.each(partitions, &Partition.lock(&1))
  end
end
