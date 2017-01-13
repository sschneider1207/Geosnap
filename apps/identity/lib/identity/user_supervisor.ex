alias Experimental.DynamicSupervisor
defmodule Identity.UserSupervisor do
  use DynamicSupervisor
  alias Identity.User

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @doc false
  def init([]) do
    children = [
      worker(User.Server, [], [restart: :transient])
    ]

    {:ok, children, strategy: :one_for_one}
  end
end
