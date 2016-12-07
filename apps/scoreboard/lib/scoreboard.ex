defmodule Scoreboard do
  @moduledoc """
  Supervisor for a ets-based distrubuted counter system.
  """
  use Supervisor

  @type t :: atom

  @doc """
  Starts a scoreboard supervisor.
  """
  @spec start_link(t, integer) :: Supervisor.on_start
  def start_link(name, partitions \\ 1) when partitions > 0 do
    Supervisor.start_link(__MODULE__, [name, partitions], name: name)
  end

  @doc false
  def init([name, partitions]) do
    {partition_specs, table_data} =
      for n <- 0..(partitions-1) do
        partition_name = Module.concat(Scoreboard, "Partition" <> Integer.to_string(n))
        spec = worker(Scoreboard.Partition, [partition_name], [id: partition_name])
        table_data = {n, partition_name}
        {spec, table_data}
      end
      |> Enum.unzip()

    children = [
      worker(Scoreboard.NodeManager, [name, partitions, table_data])
    ]

    supervise(children ++ partition_specs, strategy: :one_for_one)
  end
end
