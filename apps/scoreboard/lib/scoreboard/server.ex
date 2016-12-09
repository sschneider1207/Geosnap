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
      partitions: []
    ]
  end

  @type key :: term
  @type upvote :: 1
  @type downvote :: -1
  @type vote :: upvote | downvote

  @doc """
  Starts a node manager process.
  """
  @spec start_link(Scoreboard.t, [{integer, Partition.t}]) :: GenServer.on_start
  def start_link(scoreboard, partition_indices) do
    GenServer.start_link(__MODULE__, [scoreboard, partition_indices], [name: scoreboard])
  end

  @doc """
  Looks up the integer value for a given key.
  """
  @spec lookup(Scoreboard.t, key) :: {:ok, integer} | {:error, :not_found}
  def lookup(scoreboard, key) do
    partition = partition_for(scoreboard, key)
    try do
      :ets.lookup_element(partition, key, 2)
    rescue
      ArgumentError -> {:error, :not_found}
    else
      value -> {:ok, value}
    end
  end

  @doc """
  Inserts a new counter for the given key, if it does not already exist.
  """
  @spec put_new(Scoreboard.t, key, integer) :: {:ok, integer} | {:error, :already_exists | :locked}
  def put_new(scoreboard, key, initial_value \\ 0) do
    partition = partition_for(scoreboard, key)
    Partition.execute partition, fn p ->
      case :ets.insert_new(p, {key, initial_value}) do
          true -> {:ok, initial_value}
          false -> {:error, :already_exists}
      end
    end
  end

  @doc """
  Updates the score for a key by the given increment.
  """
  @spec update_score(Scoreboard.t, key, vote) :: {:ok, integer} | {:error, :not_found | :locked}
  def update_score(scoreboard, key, inc) when inc == 1 or inc == -1 do
    partition = partition_for(scoreboard, key)
    Partition.execute partition, fn p ->
      try do
        :ets.update_counter(p, key, inc)
      rescue
        ArgumentError -> {:error, :not_found}
      else
        new_value -> {:ok, new_value}
      end
    end
  end

  @doc """
  Overwrites the score for a key with the given value
  """
  @spec set_score(Scoreboard.t, key, integer) :: {:ok, integer} | {:error, :not_found | :locked}
  def set_score(scoreboard, key, value) do
    partition = partition_for(scoreboard, key)
    Partition.execute partition, fn p ->
      case :ets.update_element(p, key, {2, value}) do
        true -> {:ok, value}
        false -> {:error, :not_found}
      end
    end
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
  def init([scoreboard, partition_indices]) do
    num_partitions = length(partition_indices)
    scoreboard = :ets.new(scoreboard, [:named_table, {:read_concurrency, true}])
    true = :ets.insert(scoreboard, {scoreboard, num_partitions})
    true = :ets.insert(scoreboard, partition_indices)
    partition_names = Enum.map(partition_indices, &elem(&1, 1))
    state = struct(State, [scoreboard: scoreboard, partitions: partition_names])
    {:ok, state}
  end

  @doc false
  def handle_call(:lock, _from, state) do
    Enum.each(state.partitions, &Partition.lock(&1))
    {:reply, :ok, state}
  end
  def handle_call(:unlock, _from, state) do
    Enum.each(state.partitions, &Partition.unlock(&1))
    {:reply, :ok, state}
  end

  defp partition_for(scoreboard, key) do
    partitions = :ets.lookup_element(scoreboard, scoreboard, 2)
    hash = :erlang.phash2(key, partitions)
    :ets.lookup_element(scoreboard, hash, 2)
  end
end
