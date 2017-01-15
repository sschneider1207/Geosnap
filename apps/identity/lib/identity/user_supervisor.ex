alias Experimental.DynamicSupervisor
defmodule Identity.UserSupervisor do
  @moduledoc """
  Supervisor for `Identity.User.Server` processes.
  """
  use DynamicSupervisor
  alias Identity.User

  @doc """
  Starts the supervisor.
  """
  @spec start_link :: Supervisor.on_start
  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @doc """
  Starts a new user process.

  The starting parameter is either an existing
  `Identity.User` struct or a map of params to create a
  new user.
  """
  @spec start_child(User.t | map) :: Supervisor.on_start_child
  def start_child(param) do
    DynamicSupervisor.start_child(__MODULE__, [param])
  end

  @doc false
  def init([]) do
    children = [
      worker(User.Server, [], [restart: :transient])
    ]

    {:ok, children, strategy: :one_for_one}
  end
end
