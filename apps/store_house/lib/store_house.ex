defmodule StoreHouse do
  @moduledoc """
  Documentation for StoreHouse.
  """
  alias StoreHouse.{ApiKey, Application, User, Picture, Vote, Score, Comment, Utils}
  require Application
  require ApiKey

  @doc """
  Hello world.

  ## Examples

      iex> StoreHouse.hello
      :world

  """
  def hello do
    :world
  end

  @doc """
  Creates a new application and associated api keys.
  """
  @spec new_application(map) ::
    {:aborted, term} |
    {:atomic, {Application.t, ApiKey.t, ApiKey.t}}
  def new_application(params) do
    name = params["name"]
    email = params["email"]
    case Utils.check_confirmation("email", params) do
      false -> {:aborted, :emails_do_not_match}
      true -> :mnesia.transaction(&write_new_app/2, [name, email])
    end
  end

  defp write_new_app(name, email) do
    true = unique_app_name?(name)
    case Application.new(name, email) do
      {:error, reason} -> :mnesia.abort(reason)
      {:ok, app} ->
        :ok = :mnesia.write(app)
        primary_api_key = new_api_key(app)
        secondary_api_key = new_api_key(app)
        :ok = :mnesia.write(primary_api_key)
        :ok = :mnesia.write(secondary_api_key)
        {
          Application.struct(app), 
          ApiKey.struct(primary_api_key), 
          ApiKey.struct(secondary_api_key)
        }
    end
  end

  defp unique_app_name?(name) do
    :qlc_queries.application_by_name(name)
    |> :qlc.e()
    |> case do
      [_] -> :mnesia.abort(:name_not_unique)
      _ -> true
    end
  end

  defp new_api_key(app) do
    Application.application(app, :key)
    |> ApiKey.new()
  end

  @doc """
  Change the email on an application by providing a confirmed new email.
  """
  @spec change_application_email(String.t, map) :: 
    {:atomic, Application.t} |
    {:aborted, term}
  def change_application_email(app_key, params) do
    new_email = params["email"]
    case Utils.check_confirmation("email", params) do
      true -> :mnesia.transaction(&write_app_email/2, [app_key, new_email])
      false -> {:aborted, :emails_do_not_match}
    end
  end

  defp write_app_email(app_key, new_email) do
    app = read_or_abort(:application, app_key)
    case Application.change_email(app, new_email) do
    {:ok, new_app} ->
      :ok = :mnesia.write(new_app)
      Application.struct(new_app)
    {:error, reason} ->
      :mnesia.abort(reason)
    end 
  end

  defp read_or_abort(table, key) do
    case :mnesia.read(table, key) do
      [r|_] -> r
      [] -> :mnesia.abort(:"#{table}_not_found")
    end
  end
  
  @doc """
  Retrieve an application by it's associated api key.
  """
  @spec get_application(binary) ::
    {:atomic, Application.t} |
    {:aborted, term}
  def get_application(api_key) do
    :mnesia.transaction(&get_app_by_api_key/1, [api_key])
  end

  defp get_app_by_api_key(api_key_key) do
    api_key = read_or_abort(:api_key, api_key_key)
    app_key = ApiKey.api_key(api_key, :application_key)
    read_or_abort(:application, app_key)
    |> Application.struct()
  end

  def rotate_api_key(api_key_key) do
    :mnesia.transaction(&delete_write_new_api_key/1, [api_key_key])
  end

  defp delete_write_new_api_key(api_key_key) do
    api_key = read_or_abort(:api_key, api_key_key)
    :ok = :mnesia.delete({:api_key, api_key_key})
    app_key = ApiKey.api_key(api_key, :application_key)
    new_api_key = ApiKey.new(app_key)
    :ok = :mnesia.write(new_api_key)
    ApiKey.struct(new_api_key)
  end

end
