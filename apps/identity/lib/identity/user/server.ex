defmodule Identity.User.Server do
  @moduledoc """
  Process that represents a `Identity.User` struct.  Each is registered
  by the username of the struct it is in change of.
  """
  use GenServer
  alias Identity.{Repo, User, UserRegistry}

  @doc """
  Starts a new user process.

  Processes can be started with either an existing `Identity.User` struct,
  or with a map of parameters for a new user.
  """
  @spec start_link(User.t | map) :: GenServer.on_start
  def start_link(%User{username: username} = schema) do
    GenServer.start_link(__MODULE__, [schema], name: UserRegistry.via(username))
  end
  def start_link(params) when is_map(params) do
    GenServer.start_link(__MODULE__, [params])
  end

  @doc """
  Verifies the email for a user.
  """
  @spec verify_email(UserRegistry.key) :: :ok
  def verify_email(username) do
    GenServer.call(UserRegistry.via(username), :verify_email)
  end

  @doc """
  Changes the password for a user.

  Expects a map with a new password and a confirmation field.
  """
  @spec change_password(UserRegistry.key, map) :: :ok | {:error, map}
  def change_password(username, params) do
    GenServer.call(UserRegistry.via(username), {:change_password, params})
  end

  @doc """
  Changes the email for a user.

  Expects a map with a new password and a confirmation field.
  """
  @spec change_email(UserRegistry.key, map) :: :ok | {:error, map}
  def change_email(username, params) do
    GenServer.call(UserRegistry.via(username), {:change_email, params})
  end

  @doc """
  Updates the permissions for a user.
  """
  @spec update_permissions(UserRegistry.key, non_neg_integer) :: :ok | {:error, map}
  def update_permissions(username, value) do
    GenServer.call(UserRegistry.via(username), {:update_permissions, value})
  end

  @doc false
  def init([%User{} = schema]) do
    :ok = UserRegistry.update_schema!(schema)
    {:ok, schema}
  end
  def init([params]) do
    params
    |> User.new_changeset()
    |> Repo.insert()
    |> case do
      {:ok, schema} ->
        {:ok, _owner} = UserRegistry.register(schema)
        {:ok, schema}
      {:error, changeset} ->
        {:stop, changeset}
    end
  end

  @doc false
  def handle_call(:verify_email, _from, %User{verified_email: true} = schema) do
    {:reply, :ok, schema}
  end
  def handle_call(:verify_email, _from, schema) do
    updated_schema = do_update!(:verify_email_changeset, [schema])
    {:reply, :ok, updated_schema}
  end
  def handle_call({:change_password, params}, _from, schema) do
    case do_update(:change_password_changeset, [schema, params]) do
      {:ok, updated_schema} ->
        {:reply, :ok, updated_schema}
      {:error, changeset} ->
        {:reply, {:error, changeset}, schema}
    end
  end
  def handle_call({:change_email, params}, _from, schema) do
    case do_update(:change_email_changeset, [schema, params]) do
      {:ok, updated_schema} ->
        {:reply, :ok, updated_schema}
      {:error, changeset} ->
        {:reply, {:error, changeset}, schema}
    end
  end
  def handle_call({:update_permissions, value}, _from, schema) do
    case do_update(:update_permissions_changeset, [schema, value]) do
      {:ok, updated_schema} ->
        {:reply, :ok, updated_schema}
      {:error, changeset} ->
        {:reply, {:error, changeset}, schema}
    end
  end

  defp do_update!(action, params) do
    schema =
      apply(User, action, params)
      |> Repo.update!()
    :ok = UserRegistry.update_schema!(schema)
  end

  defp do_update(action, params) do
    apply(User, action, params)
    |> Repo.update()
    |> case do
      {:ok, schema} ->
        :ok = UserRegistry.update_schema!(schema)
        {:ok, schema}
      {:error, changeset} ->
        {:error, errors_to_map(changeset)}
    end
  end

  defp errors_to_map(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
