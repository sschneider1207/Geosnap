defmodule Scoreboard.Partition do
  use GenServer

  defmodule State do
    @moduledoc false
    defstruct [table: nil, locked: false]
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def transaction(name, op) do
    GenServer.call(name, {:transaction, op})
  end

  def lock(name) do
    GenServer.call(name, :lock)
  end

  def unlock(name) do
    GenServer.call(name, :unlock)
  end

  def init(name) do
    name = :ets.new(name, [:named_table, {:read_concurrency, true}])
    state = struct(State, [table: name])
    {:ok, state}
  end

  def handle_call({:transaction, _op}, _from, %{locked: true} = state) do
    {:reply, {:error, :locked}, state}
  end
  def handle_call({:transaction, op}, _from, state) do
    reply = op.()
    {:reply, reply, state}
  end
  def handle_call(:lock, state) do
    {:reply, :ok, %{state| locked: true}}
  end
  def handle_call(:unlock, state) do
    {:reply, :ok, %{state| locked: false}}
  end
end
