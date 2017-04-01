defmodule StoreHouse.Picture do
  use StoreHouse.Table, :picture
  alias StoreHouse.Utils
  import Utils, only: [is_coordinate: 1]

  @doc """
  Create a new picture record.
  """
  @spec new(String.t, {integer, integer}, String.t, integer, integer, integer)
    :: {:ok, tuple} |
       {:error, term}
  def new(title, loc, hash, user, cat, app) when is_coordinate(loc) do
    {:ok, row = picture([
      key: Utils.new_key(), # look into geohashing
      title: title,
      location: loc,
      hash: hash,
      user_key: user,
      category_key: cat,
      application_key: app,
      inserted_at: Utils.timestamp(),
      updated_at: Utils.timestamp()
    ])}
  end
  def new(_, _, _, _, _, _) do
    {:error, :invalid_location}
  end

  @doc """
  Sets the picture and thumbnail path fields on a picture record.
  """
  @spec set_paths(tuple, String.t, String.t) :: tuple
  def set_paths(picture, p_path, t_path) do
    picture(picture, [
      picture_path: p_path,
      thumbnail_path: t_path,
      updated_at: Utils.timestamp()
    ])
  end
end
