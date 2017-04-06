defmodule StoreHouse do
  @moduledoc """
  Documentation for StoreHouse.
  """
  alias StoreHouse.{ApiKey, Application, User, Picture, Vote, Score, Comment}
  require Application

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
  Creates a new application and associated api key.
  """
  @spec new_application(map) ::
    {:aborted, term} |
    {:atomic, {Application.t, ApiKey.t}}
  def new_application(params) do
    name = params["name"]
    email = params["email"]
    case Application.new(name, email) do
      {:error, reason} -> 
        {:aborted, reason}
      {:ok, app} ->
        :mnesia.transaction(&insert_new_app/1, [app])
    end
  end

  defp insert_new_app(app) do
    Application.application(app, :name)
    |> :qlc_queries.application_by_name()
    |> :qlc.e()
    |> case do
      [_] -> :mnesia.abort(:name_not_unique)
      _ ->
        :mnesia.write(app)
        api_key =
          Application.application(app, :key)
          |> ApiKey.new()
        :mnesia.write(api_key)
        {Application.struct(app), ApiKey.struct(api_key)}
    end
  end
end
