defmodule Identity.UserRegistry do
  @moduledoc """
  Registery helpers for `Identity.User.Server` processes.

  `Identity.User` schemas are backed by `Identity.User.Server` processes which
  registry themselves by the id found in the schema.  The registry is set to use
  partitions equal to the number of schedulers that are online, and operates as
  a single entity per node.
  """
  alias Identity.User

  @typedoc """
  The id from a `User` schema.
  """
  @type id :: non_neg_integer

  @doc """
  Starts the UserRegistry.

  Only a single one can exist on the current node at a time.
  """
  @spec start_link :: {:ok, pid} | {:error, term}
  def start_link do
    Registry.start_link(:unique, __MODULE__, [partitions: System.schedulers_online()])
  end

  @doc false
  @spec register(User.t) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register(%User{id: id} = schema) do
    Registry.register(__MODULE__, id, schema)
  end

  @doc false
  @spec via(id) :: {:via, Registry, {__MODULE__, non_neg_integer}}
  def via(id) do
    {:via, Registry, {__MODULE__, id}}
  end

  @doc """
  Looks up a user process and it's schema by id.
  """
  @spec lookup(id) :: {pid, User.t} | nil
  def lookup(id) do
    case Registry.lookup(__MODULE__, id) do
      [{_pid, nil}] -> nil
      [{pid, schema}] -> {pid, schema}
      [] -> nil
    end
  end

  @doc """
  Updates a process's registered schema.

  If the calling process is not registered under the id found in the schema, this raises.
  """
  @spec update_schema!(User.t) :: :ok | no_return
  def update_schema!(%User{id: id} = new_schema) do
    case Registry.update_value(__MODULE__, id, fn _old -> new_schema end) do
      {^new_schema, _old_schema} -> :ok
      :error -> raise "proccess #{inspect(self())} not registered under id #{id}"
    end
  end
end
