defmodule Geosnap.Db do
  alias Geosnap.Db.{Repo, Application, ApiKey, User, Picture}
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
  Changes the email for a user.
  """
  @spec change_application_email(Application.t, map) :: {:ok, Application.t} | {:error, map}
  def change_application_email(application, params) do
    do_repo_action(
      fn -> Application.change_email_changeset(application, params) end,
      &Repo.update/1
    )
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

  @doc """
  Creates a new user.
  """
  @spec new_user(map) :: {:ok, User.t} | {:error, map}
  def new_user(params) do
    do_repo_action(
      fn -> User.new_changeset(params) end,
      &Repo.insert/1
    )
  end

  @doc """
  Changes the password for a user.
  """
  @spec change_user_password(User.t, map) :: {:ok, User.t} | {:error, map}
  def change_user_password(user, params) do
    do_repo_action(
      fn -> User.change_password_changeset(user, params) end,
      &Repo.update/1
    )
  end

  @doc """
  Changes the email for a user.
  """
  @spec change_user_email(User.t, map) :: {:ok, User.t} | {:error, map}
  def change_user_email(user, params) do
    do_repo_action(
      fn -> User.change_email_changeset(user, params) end,
      &Repo.update/1
    )
  end

  @doc """
  Get a user by either user id or username.
  """
  @spec get_user(integer | String.t) :: User.t | nil
  def get_user(user_id) when is_integer(user_id) do
    Repo.get(User, user_id)
  end
  def get_user(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Creates a new picture.
  """
  @spec new_picture(map) :: {:ok, Picture.t} | {:error, map}
  def new_picture(params) do
    do_repo_action(
      fn -> Picture.new_changeset(params) end,
      &Repo.insert/1
    )
  end

  @doc """
  Deletes a picture.
  """
  @spec delete_picture(Picture.t) :: :ok | {:error, map}
  def delete_picture(picture) do
    case Repo.delete(picture) do
      {:ok, _picture} ->
        :ok
      {:error, changeset} ->
        {:error, errors_to_map(changeset)}
    end
  end

  @doc """
  Gets pictures around a longitude-latitude pair.
  """
  @spec get_pictures(float, float, Keyword.t) :: [Picture.t]
  def get_pictures(lng, lat, opts \\ []) do
    import PostGIS
    point = %Point{coordinates: {lng, lat}, srid: 4236}
    radius = Keyword.get(opts, :radius, 1_000)
    limit = Keyword.get(opts, :limit, 24)
    offset = Keyword.get(opts, :offset, 0)

    from p in Picture,
      where: st_dwithin(p.point, ^point, ^radius),
      limit: ^limit,
      offset: ^offset
    |> Repo.all()
  end

  defp do_repo_action(gen_changeset, repo_action) do
    with %{valid?: true} = changeset <- gen_changeset.(),
      {:ok, schema} <- repo_action.(changeset) do
        {:ok, schema}
    else
      {:error, changeset} ->
        {:error, errors_to_map(changeset)}
      changeset ->
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
