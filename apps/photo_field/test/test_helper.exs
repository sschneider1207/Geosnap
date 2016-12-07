ExUnit.start()

defmodule TestHelper do
  alias Geosnap.Db

  def picture_params(params) do
    %{
      title: :crypto.strong_rand_bytes(16)  |> Base.encode16(),
      location: %Geo.Point{
        coordinates: {120,-60},
        srid: 4326
      },
      expiration: Timex.now() |> Timex.shift([hours: 1]),
      picture_path: "/path/to/pic",
      thumbnail_path: "/path/to/thumbnail",
      md5: :crypto.strong_rand_bytes(16)  |> Base.encode64(),
      user_id: 1,
      category_id: 1
    }
    |> Map.merge(params)
  end

  def user() do
    import Ecto.Query
    Db.Repo.one(from u in Db.User, limit: 1)
  end

  def category() do
    import Ecto.Query
    Db.Repo.one(from c in Db.Category, limit: 1)
  end

  def new_picture(picture_params \\ %{}) do
    user = user()
    category = category()
    {:ok, picture} =
      %{user_id: user.id, category_id: category.id}
      |> Map.merge(picture_params)
      |> picture_params()
      |> Db.new_picture()
    {user, category, picture}
  end

  def kill(pid) do
    GenServer.stop(pid)
  end

  def delete_all_pictures do
    Db.Repo.delete_all(Db.Picture)
  end
end
