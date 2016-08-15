defmodule Geosnap.Db do
  alias Geosnap.Db.{Repo, Application, ApiKey}
  import Ecto.Query

  @doc """
  Creates a new application with the given params.
  Includes an api_key.
  """
  @spec new_application(map) :: {:ok, Application.t} | {:error, map}
  def new_application(params) do
    with %{valid?: true} = app_changeset <- Application.new_changeset(params),
      {:ok, application} <- Repo.insert(app_changeset),
      key_changeset = ApiKey.new_changeset(application.id),
      {:ok, api_key} <- Repo.insert(key_changeset) do
        {:ok, %{application | api_key: api_key}}
    else
      {:error, changeset} ->
        {:error, errors_to_map(changeset)}
      changeset ->
        {:error, errors_to_map(changeset)}
    end
  end

  @doc """
  Generates a new api key for an application.
  Existing api key is not required to be known.
  """
  @spec rotate_application_key(Application.t) :: {:ok, Application.t} | {:error, map}
  def rotate_application_key(application) do
    application = Repo.preload(application, :api_key)
    changeset = ApiKey.rotate_key_changeset(application.api_key)
    case Repo.insert(changeset) do
      {:ok, api_key} ->
        {:ok, %{application | api_key: api_key}}
      {:error, changeset} ->
        {:error, errors_to_map(changeset)}
    end
  end

  @doc """
  Gets an application by the public key of it's api key.
  """
  @spec get_application(String.t) :: Application.t
  def get_application(public_key) do
    query = from a in Application,
      join: k in assoc(a, :api_key),
      where: k.public_key == ^public_key,
      preload: [api_key: k]
    case Repo.one(query) do
      nil -> {:error, :not_found}
      application -> {:ok, application}
    end
  end

  defp errors_to_map(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(msg, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
