defmodule Scoreboard.NodeManager do
  @moduledoc """
  Process that manages the scoreboard ets tables for the current node.
  """
  use GenServer

  @type key :: term
  @type upvote :: 1
  @type downvote :: -1
  @type vote :: upvote | downvote

  defmacrop transaction(partition, block) do
    quote location: :keep do
      Scoreboard.Partition.transaction(unquote(partition), fn ->
        [do: result] = unquote(block)
        result
      end)
    end
  end

  @doc """
  Starts a node manager process.
  """
  @spec start_link(Scoreboard.t, integer, [tuple]) :: GenServer.on_start
  def start_link(scoreboard, partitions, init_data) do
    GenServer.start_link(__MODULE__, [scoreboard, partitions, init_data], [name: __MODULE__])
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
    transaction(partition) do
      case :ets.insert_new(partition, {key, initial_value}) do
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
    transaction(partition) do
      try do
        :ets.update_counter(partition, key, inc)
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
    transaction(partition) do
      case :ets.update_element(partition, key, {2, value}) do
        true -> {:ok, value}
        false -> {:error, :not_found}
      end
    end
  end

  @doc false
  def init([scoreboard, partitions, init_data]) do
    scoreboard = :ets.new(scoreboard, [:named_table, {:read_concurrency, true}])
    true = :ets.insert(scoreboard, {scoreboard, partitions})
    true = :ets.insert(scoreboard, init_data)
    {:ok, scoreboard}
  end

  defp partition_for(scoreboard, key) do
    partitions = :ets.lookup_element(scoreboard, scoreboard, 2)
    hash = :erlang.phash2(key, partitions)
    :ets.lookup_element(scoreboard, hash, 2)
  end
end
