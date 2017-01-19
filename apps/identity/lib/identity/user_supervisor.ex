defmodule Identity.UserSupervisor do
  @moduledoc """
  Supervisor for `Identity.User.Server` processes.
  """
  use Supervisor
  alias Identity.User

  @doc """
  Starts the supervisor.
  """
  @spec start_link :: Supervisor.on_start
  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @doc """
  Starts a new user process.

  The starting parameter is either an existing
  `Identity.User` struct or a map of params to create a
  new user.
  """
  @spec start_child(User.t | map) :: Supervisor.on_start_child
  def start_child(param) do
    Supervisor.start_child(__MODULE__, [param])
  end

  @doc false
  def init(start_opts) do
    children = [
      worker(User.Server, [start_opts], [restart: :transient])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
