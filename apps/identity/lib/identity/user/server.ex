defmodule Identity.User.Server do
  @moduledoc """
  Process that represents a `Identity.User` struct.  Each is registered
  by the username of the struct it is in change of.
  """
  use GenServer
  alias Identity.{Repo, User, UserRegistry}
  require Logger

  defmodule State do
    @moduledoc false
    @default_expiration 1 * 24 * 60 * 60 * 1_000 # 1 day
    defstruct [
      schema: nil,
      expr_ref: nil,
      expr_ms: @default_expiration
    ]

    @spec new(Keyword.t) :: %__MODULE__{}
    def new(params \\ []) do
      struct(__MODULE__, params)
    end

    @spec update(%__MODULE__{}, Keyword.t) :: %__MODULE__{}
    def update(struct, params) do
      struct(struct, params)
    end
  end

  @doc """
  Starts a new user process.

  Processes can be started with either an existing `Identity.User` struct,
  or with a map of parameters for a new user.
  """
  @spec start_link(Keyword.t, User.t | map) :: GenServer.on_start
  def start_link(opts \\ [], seed)
  def start_link(opts, %User{username: username} = schema) do
    GenServer.start_link(__MODULE__, [schema, opts], name: UserRegistry.via(username))
  end
  def start_link(opts, params) when is_map(params) do
    GenServer.start_link(__MODULE__, [params, opts])
  end

  @doc """
  Verifies the email for a user.
  """
  @spec verify_email(UserRegistry.key | pid) :: :ok
  def verify_email(name) do
    name
    |> server_name()
    |> GenServer.call(:verify_email)
  end

  @doc """
  Changes the password for a user.

  Expects a map with a new password and a confirmation field.
  """
  @spec change_password(UserRegistry.key | pid, map) :: :ok | {:error, map}
  def change_password(name, params) do
    name
    |> server_name()
    |> GenServer.call({:change_password, params})
  end

  @doc """
  Changes the email for a user.

  Expects a map with a new password and a confirmation field.
  """
  @spec change_email(UserRegistry.key | pid, map) :: :ok | {:error, map}
  def change_email(name, params) do
    name
    |> server_name()
    |> GenServer.call({:change_email, params})
  end

  @doc """
  Updates the permissions for a user.
  """
  @spec update_permissions(UserRegistry.key | pid, non_neg_integer) :: :ok | {:error, map}
  def update_permissions(name, value) do
    name
    |> server_name()
    |> GenServer.call({:update_permissions, value})
  end

  @doc """
  Deletes the user.
  """
  @spec delete(UserRegistry.key | pid) :: :ok
  def delete(name) do
    name
    |> server_name()
    |> GenServer.call(:delete)
  end

  defp server_name(username) when is_bitstring(username) do
    UserRegistry.via(username)
  end
  defp server_name(pid) when is_pid(pid) do
    pid
  end

  @doc false
  def init([%User{} = schema, opts]) do
    :ok = UserRegistry.update_schema!(schema)
    do_init(schema, opts)
  end
  def init([params, opts]) do
    params
    |> User.new_changeset()
    |> Repo.insert()
    |> case do
      {:ok, schema} ->
        {:ok, _owner} = UserRegistry.register(schema)
        do_init(schema, opts)
      {:error, changeset} ->
        {:stop, changeset}
    end
  end

  def do_init(schema, opts) do
    Logger.metadata(user: schema.id)
    state =
      State.new([schema: schema] ++ opts)
      |> schedule_expiration()
    {:ok, state, :hibernate}
  end

  @doc false
  def handle_call(:verify_email, _from, %{schema: %User{verified_email: true}} = state) do
    state = schedule_expiration(state)
    {:reply, :ok, state, :hibernate}
  end
  def handle_call(:verify_email, _from, state) do
    updated_schema = do_update!(:verify_email_changeset, [state.schema])
    state =
      state
      |> schedule_expiration()
      |> State.update(schema: updated_schema)
    {:reply, :ok, state, :hibernate}
  end
  def handle_call({:change_password, params}, _from, state) do
    case do_update(:change_password_changeset, [state.schema, params]) do
      {:ok, updated_schema} ->
        state =
          state
          |> schedule_expiration()
          |> State.update(schema: updated_schema)
        {:reply, :ok, state, :hibernate}
      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end
  def handle_call({:change_email, params}, _from, state) do
    case do_update(:change_email_changeset, [state.schema, params]) do
      {:ok, updated_schema} ->
        state =
          state
          |> schedule_expiration()
          |> State.update(schema: updated_schema)
        {:reply, :ok, state, :hibernate}
      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end
  def handle_call({:update_permissions, value}, _from, state) do
    case do_update(:update_permissions_changeset, [state.schema, value]) do
      {:ok, updated_schema} ->
        state =
          state
          |> schedule_expiration()
          |> State.update(schema: updated_schema)
        {:reply, :ok, state, :hibernate}
      {:error, changeset} ->
        {:reply, {:error, changeset}, state}
    end
  end
  def handle_call(:delete, _from, state) do
    deleted_schema = Repo.delete!(state.schema)
    # just in case someone grabs this before it stops
    :ok = UserRegistry.update_schema!(deleted_schema)
    {:stop, :normal, :ok, state}
  end

  @doc false
  def handle_info(:expired, state) do
    Logger.debug("user proccess expired")
    {:stop, :normal, state}
  end

  defp schedule_expiration(%State{expr_ref: nil} = state) do
    do_schedule_expiration(state)
  end
  defp schedule_expiration(state) do
    rem = cancel_expiration(state.expr_ref)
    Logger.debug("cancelled expiration timer", remaining_ms: rem)
    do_schedule_expiration(state)
  end

  defp do_schedule_expiration(state) do
    ref = Process.send_after(self(), :expired, state.expr_ms)
    %{state| expr_ref: ref}
  end

  defp cancel_expiration(ref) do
    case Process.cancel_timer(ref) do
      false ->
        receive do
          :expired ->
            0
        after
          0 ->
            0
        end
      rem ->
        rem
    end
  end

  defp do_update!(action, params) do
    schema =
      apply(User, action, params)
      |> Repo.update!()
    :ok = UserRegistry.update_schema!(schema)
    schema
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
