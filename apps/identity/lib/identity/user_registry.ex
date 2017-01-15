defmodule Identity.UserRegistry do
  @moduledoc """
  Registery helpers for `Identity.User.Server` processes.

  `Identity.User` schemas are backed by `Identity.User.Server` processes which
  registry themselves by the username found in the schema.  The registry is set to use
  partitions equal to the number of schedulers that are online, and operates as
  a single entity per node.
  """
  alias Identity.User

  @typedoc """
  The username from a `User` schema.
  """
  @type key :: String.t

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
  def register(%User{username: username} = schema) do
    Registry.register(__MODULE__, username, schema)
  end

  @doc false
  @spec via(key) :: {:via, Registry, {__MODULE__, key}}
  def via(username) do
    {:via, Registry, {__MODULE__, username}}
  end

  @doc """
  Looks up a user process and it's schema by username or pid.
  """
  @spec lookup(key | pid) :: {pid, User.t} | nil
  def lookup(username) when is_bitstring(username) do
    case Registry.lookup(__MODULE__, username) do
      [{_pid, nil}] -> nil
      [{pid, schema}] -> {pid, schema}
      [] -> nil
    end
  end
  def lookup(pid) when is_pid(pid) do
    case Registry.keys(__MODULE__, pid) do
      [] -> nil
      [username] -> lookup(username)
    end
  end

  @doc """
  Updates a process's registered schema.

  If the calling process is not registered under the username found in the
  schema, this raises.
  """
  @spec update_schema!(User.t) :: :ok | no_return
  def update_schema!(%User{username: username} = new_schema) do
    case Registry.update_value(__MODULE__, username, fn _old -> new_schema end) do
      {^new_schema, _old_schema} -> :ok
      :error -> raise "proccess #{inspect(self())} not registered under username #{username}"
    end
  end
end
