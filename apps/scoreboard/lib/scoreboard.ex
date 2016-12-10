defmodule Scoreboard do
  @moduledoc """
  Supervisor for a ets-based distrubuted counter system.
  """
  use Supervisor

  @type t :: atom

  @type key :: term

  @type vote :: upvote | downvote

  @type upvote :: 1

  @type downvote :: -1

  @type options :: [option]

  @type option ::
    {:partitions, partitions} |
    {:role, role}

  @type partitions :: pos_integer

  @type role :: :slave | {:master, module} | :local

  @type master :: node

  @doc """
  Starts a scoreboard supervisor.
  """
  @spec start_link(t, options) :: Supervisor.on_start
  def start_link(name, opts \\ []) do
    role = opt(:role, opts)
    partitions = opt(:partitions, opts)
    Supervisor.start_link(__MODULE__, [name, role, partitions], name: Module.concat(name, "Supervisor"))
  end

  defp opt(:role, opts) do
    case Keyword.get(opts, :role, :local) do
      :local -> :local
      :slave -> {:slave, nil}
      {:master, relink_strat} -> {:master, relink_strat}
      term -> raise "Expected role of either {:slave, master} or {:master, relink_strategy}, got #{term}"
    end
  end
  defp opt(:partitions, opts) do
    case Keyword.get(opts, :partitions, 1) do
      n when n >= 1 -> n
      term -> raise "Expected a positive number of partitions, got #{term}"
    end
  end

  @doc false
  def init([name, role, num_partitions]) do
    {partition_specs, partition_indices} =
      for p <- 0..(num_partitions-1) do
        partition_name = Module.concat(Scoreboard, "Partition" <> Integer.to_string(p))
        spec = worker(Scoreboard.Partition, [partition_name], [id: partition_name])
        partition_index = {p, partition_name}
        {spec, partition_index}
      end
      |> Enum.unzip()

    children = [
      worker(Scoreboard.Server, [name, role, partition_indices])
    ]

    supervise(partition_specs ++ children, strategy: :one_for_one)
  end
end
