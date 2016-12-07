defmodule PhotoField.PhotoRegistry do
  @moduledoc """
  `Registry` helper functions for a photo registry.
  """
  alias Geosnap.Db.Picture

  @doc """
  Starts a board registry process.
  """
  @spec start_link(Registry.options) ::
    {:ok, pid} |
    {:error, term}
  def start_link(opts \\ []) do
    Registry.start_link(:unique, __MODULE__, opts)
  end

  @doc """
  Registers a new picture.
  """
  @spec register(Picture.t) ::
    {:ok, pid} |
    {:error, {:already_registered, pid}}
  def register(picture) do
    Registry.register(__MODULE__, picture.id, picture)
  end

  @doc """
  Unregisters a new picture.
  """
  @spec unregister(Picture.t) ::
    {:ok, pid} |
    {:error, {:already_registered, pid}}
  def unregister(picture) do
    Registry.unregister(__MODULE__, picture.id)
  end

  @doc """
  Looks up a picture by id.
  """
  @spec lookup(integer) :: Picture.t | nil
  def lookup(id) do
    case Registry.lookup(__MODULE__, id) do
      [] -> nil
      [{_pid, picture}] -> picture
    end
  end
end
