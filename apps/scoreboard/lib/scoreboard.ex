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
  def start_link(name, opts \\ []) do
    partitions = opt(:partitions, opts)
    Supervisor.start_link(__MODULE__, [name, partitions], name: Module.concat(name, "Supervisor"))
  end

  defp opt(:partitions, opts) do
    case Keyword.get(opts, :partitions, 1) do
      n when n >= 1 -> n
      term -> raise "Expected a positive number of partitions, got #{term}"
    end
  end

  @doc false
  def init([name, num_partitions]) do
    {partition_specs, partition_indices} =
      for p <- 0..(num_partitions-1) do
        partition_name = Module.concat(Scoreboard, "Partition" <> Integer.to_string(p))
        spec = worker(Scoreboard.Partition, [partition_name], [id: partition_name])
        partition_index = {p, partition_name}
        {spec, partition_index}
      end
      |> Enum.unzip()

    children = [
      worker(Scoreboard.Server, [name, partition_indices])
    ]

    supervise(children ++ partition_specs, strategy: :one_for_one)
  end
end
