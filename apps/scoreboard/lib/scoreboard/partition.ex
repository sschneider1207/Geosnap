defmodule Scoreboard.Partition do
  @moduledoc """
  Genserver process that manages a partition's ets table and transactions.
  """
  use GenServer

  @type t :: atom

  defmodule State do
    @moduledoc false
    defstruct [
      locked: true,
      partition: nil,
      buffer: :queue.new()
    ]
  end

  @doc """
  Starts a new partition genserver process.
  """
  @spec start_link(t) :: GenServer.on_start
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Looks up the integer value for a given key.
  """
  @spec lookup(t, Scoreboard.key) :: {:ok, integer} | {:error, :not_found}
  def lookup(partition, key) do
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
  @spec put_new(t, Scoreboard.key, integer) ::
    {:ok, integer} |
    {:error, :already_exists} |
    :buffered
  def put_new(name, key, initial_value \\ 0) do
    GenServer.call(name, {:put_new, {key, initial_value}})
  end

  @doc """
  Updates the score for a key by the given increment.
  """
  @spec update(t, Scoreboard.key, Scoreboard.vote) ::
    {:ok, integer} |
    {:error, :not_found} |
    :buffered
  def update(name, key, inc) when inc == 1 or inc == -1 do
    GenServer.call(name, {:update, {key, inc}})
  end

  @doc """
  Overwrites the score for a key with the given value
  """
  @spec set(t, Scoreboard.key, integer) ::
    {:ok, integer} |
    {:error, :not_found} |
    :buffered
  def set(name, key, value) do
    GenServer.call(name, {:set, {key, value}})
  end

  @doc """
  Locks the partition, preventing it from being used.
  """
  @spec lock(t) :: :ok
  def lock(name) do
    GenServer.call(name, :lock)
  end

  @doc """
  UnlLocks the partition, enabling it to be used.
  """
  @spec unlock(t) :: :ok
  def unlock(name) do
    GenServer.call(name, :unlock)
  end

  @doc false
  def init(partition) do
    partition = :ets.new(partition, [:named_table, {:read_concurrency, true}])
    state = struct(State, [partition: partition])
    {:ok, state}
  end

  @doc false
  def handle_call({:put_new, {key, initial_value}}, _from, %{locked: true} = state) do
    action = &do_put_new(&1, key, initial_value)
    buf = :queue.in(action, state.buffer)
    {:reply, :buffered, %{state| buffer: buf}}
  end
  def handle_call({:put_new, {key, initial_value}}, _from, state) do
    reply = do_put_new(state.partition, key, initial_value)
    {:reply, reply, state}
  end
  def handle_call({:update, {key, increment}}, _from, %{locked: true} = state) do
    action = &do_update(&1, key, increment)
    buf = :queue.in(action, state.buffer)
    {:reply, :buffered, %{state| buffer: buf}}
  end
  def handle_call({:update, {key, increment}}, _from, state) do
    reply = do_update(state.partition, key, increment)
    {:reply, reply, state}
  end
  def handle_call({:set, {key, value}}, _from, %{locked: true} = state) do
    action = &do_set(&1, key, value)
    buf = :queue.in(action, state.buffer)
    {:reply, :buffered, %{state| buffer: buf}}
  end
  def handle_call({:set, {key, value}}, _from, state) do
    reply = do_set(state.partition, key, value)
    {:reply, reply, state}
  end
  def handle_call(:lock, _from, state) do
    {:reply, :ok, %{state| locked: true}}
  end
  def handle_call(:unlock, _from, state) do
    execute_buffer(:queue.to_list(state.buffer), state.partition)
    {:reply, :ok, %{state| locked: false, buffer: :queue.new()}}
  end

  defp do_put_new(partition, key, initial_value) do
    case :ets.insert_new(partition, {key, initial_value}) do
        true -> {:ok, initial_value}
        false -> {:error, :already_exists}
    end
  end

  defp do_update(partition, key, increment) do
    try do
      :ets.update_counter(partition, key, increment)
    rescue
      ArgumentError -> {:error, :not_found}
    else
      new_value -> {:ok, new_value}
    end
  end

  defp do_set(partition, key, value) do
    case :ets.update_element(partition, key, {2, value}) do
      true -> {:ok, value}
      false -> {:error, :not_found}
    end
  end

  defp execute_buffer([], _), do: :ok
  defp execute_buffer([h|t], p) do
    h.(p)
    execute_buffer(t, p)
  end
end
