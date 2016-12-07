defmodule PhotoField do
  @moduledoc """

  """
  use Application
  alias PhotoField.{PhotoRegistry, PhotoSupervisor, Scoreboard}
  alias Geosnap.Db
  alias Db.Picture

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    partitions = System.schedulers_online()

    children = [
      worker(Scoreboard, []),
      supervisor(PhotoRegistry, [[partitions: partitions, listeners: [Scoreboard]]]),
      supervisor(PhotoSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: PhotoField.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Start a new photo process with a map of params.
  """
  @spec new(map) :: {:ok, Picture.t} | {:error, term}
  def new(params) do
    with {:ok, picture} <- Db.new_picture(params),
         {:ok, pid} <- PhotoSupervisor.spawn_photo(picture)
    do
      {:ok, picture}
    else
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Gets a picture by id.
  """
  @spec get(integer) :: Picture.t | nil
  def get(id) do
    # bit of a reverse-with here
    with nil <- PhotoRegistry.lookup(id),
         nil <- new_by_id(id)
    do
      nil
    else
      :expired -> nil
      :not_found -> nil
      {pid, picture} when is_pid(pid) -> picture
      picture -> picture
    end
  end

  defp new_by_id(id) do
    Db.get_picture(id, true)
    |> safe_new()
  end

  defp safe_new(nil) do
    :not_found
  end
  defp safe_new(picture) do
    case PhotoSupervisor.spawn_photo(picture) do
      {:error, {:duplicate, _pid}} -> picture
      {:error, :expired} -> :expired
      {:ok, _pid} -> picture
    end
  end
end
