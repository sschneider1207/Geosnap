defmodule Identity.User.Server do
  use GenServer
  alias Identity.{Repo, User, UserRegistry}

  def start_link(%User{id: id} = schema) do
    GenServer.start_link(__MODULE__, [schema], name: UserRegistry.via(id))
  end
  def start_link(params) when is_map(params) do
    GenServer.start_link(__MODULE__, [params])
  end

  def verify_email(id) do
    GenServer.call(UserRegistry.via(id), :verify_email)
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
    new_schema =
      schema
      |> User.verify_email_changeset()
      |> Repo.update!()
    :ok = UserRegistry.update_schema!(new_schema)
    {:reply, :ok, new_schema}
  end
end
