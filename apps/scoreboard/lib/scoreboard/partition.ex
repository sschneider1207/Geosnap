defmodule Scoreboard.Partition do
  @moduledoc """
  Genserver process that manages a partition's ets table and transactions.
  """
  use GenServer

  @type t :: atom

  defmodule State do
    @moduledoc false

    defstruct [locked: false, partition: nil, buffer: :queue.new()]
  end

  @doc """
  Executes the given fun on the provided transaction process.
  """
  @spec execute(t, (() -> {:ok, term} | {:error, term})) ::
      {:ok, term} |
      {:error, :locked | term}
  def execute(name, fun) do
    GenServer.call(name, {:transaction, fun})
  end

  @doc """
  Starts a new partition genserver process.
  """
  @spec start_link(t) :: GenServer.on_start
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
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
  def handle_call({:transaction, op}, _from, %{locked: true} = state) do
    buffer = :queue.in(op, state.buffer)
    {:reply, {:error, :locked}, %{state| buffer: buffer}}
  end
  def handle_call({:transaction, op}, _from, state) do
    reply = op.(state.partition)
    {:reply, reply, state}
  end
  def handle_call(:lock, _from, state) do
    {:reply, :ok, %{state| locked: true}}
  end
  def handle_call(:unlock, _from, state) do
    execute_buffer(:queue.to_list(state.buffer), state.partition)
    {:reply, :ok, %{state| locked: false, buffer: :queue.new()}}
  end

  defp execute_buffer([], _), do: :ok
  defp execute_buffer([h|t], p) do
    h.(p)
    execute_buffer(t, p)
  end
end
