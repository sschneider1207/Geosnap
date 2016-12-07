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
  def init([name, partitions]) do
    {partition_specs, table_data} =
      for p <- 0..(partitions-1) do
        partition_name = Module.concat(Scoreboard, "Partition" <> Integer.to_string(p))
        spec = worker(Scoreboard.Partition, [partition_name], [id: partition_name])
        table_data = {p, partition_name}
        {spec, table_data}
      end
      |> Enum.unzip()

    children = [
      worker(Scoreboard.Server, [name, partitions, table_data])
    ]

    supervise(children ++ partition_specs, strategy: :one_for_one)
  end
end
