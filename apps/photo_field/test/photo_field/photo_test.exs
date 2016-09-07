defmodule PhotoField.PhotoTest do
  use ExUnit.Case
  alias PhotoField.{Photo, PhotoSupervisor}
  alias Geosnap.Db

  setup_all do
    on_exit(&delete_all_pictures/0)
  end

  test "new with invalid params returns error map" do
    {:error, errors} = Photo.new(%{})

    assert is_map(errors) == true
  end

  test "new with valid params returns pid" do
    user = user()
    category = category()
    {:ok, pid} =
      %{user_id: user.id, category_id: category.id}
      |> picture_params()
      |> Photo.new()

    assert is_pid(pid) == true
    kill(pid)
  end

  test "can get picture pid by id" do
    {_user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)

    assert is_nil(pid) == false
    kill(pid)
  end

  test "get picture with non existant id returns nil" do
    pid = Photo.get(1)

    assert is_nil(pid) == true
  end

  test "can retrieve schema of picture by id" do
    {_user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    schema = Photo.get_schema(pid)

    assert picture.id == schema.id
    kill(pid)
  end

  test "can retrieve score of picture by id" do
    {_user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    score = Photo.get_score(pid)

    assert score == 0
    kill(pid)
  end

  test "voting on a picture increases score" do
    {user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    initial_score = Photo.get_score(pid)
    {:ok, vote} = Photo.vote_on(pid, user.id, 1)
    new_score = Photo.get_score(pid)

    assert vote.user_id == user.id
    assert vote.picture_id == picture.id
    assert new_score > initial_score
    kill(pid)
  end

  test "can't vote on a picture twice with the same user" do
    {user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    {:ok, _vote} = Photo.vote_on(pid, user.id, 1)
    {:error, errors} = Photo.vote_on(pid, user.id, -1)

    assert is_map(errors) == true
    kill(pid)
  end

  test "can't vote on a picture with fake user id" do
    {_user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    {:error, errors} = Photo.vote_on(pid, -1, 1)

    assert is_map(errors) == true
    kill(pid)
  end

  test "can update a vote for a user" do
    {user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    {:ok, vote} = Photo.vote_on(pid, user.id, 1)
    score = Photo.get_score(pid)
    {:ok, new_vote} = Photo.update_vote_on(pid, vote, -1)
    new_score = Photo.get_score(pid)

    assert score - vote.value + new_vote.value == new_score
    kill(pid)
  end

  test "deleted vote is subtracted from score" do
    {user, _category, picture} = new_picture()
    pid = Photo.get(picture.id)
    {:ok, vote} = Photo.vote_on(pid, user.id, 1)
    score = Photo.get_score(pid)
    :ok = Photo.delete_vote_on(pid, vote)
    new_score = Photo.get_score(pid)

    assert score - vote.value == new_score
    kill(pid)
  end

  test "expired pictures are not spawned" do
    params = picture_params(%{expiration: Timex.now() |> Timex.shift([hours: -1])})
    picture = struct(Db.Picture, params)
    {:error, reason} = Photo.start_link(:l, picture)

    assert reason == :expired
  end

  test "pictures die when expired" do
    {_user, _category, picture} = new_picture()
    picture = %{picture | expiration: Timex.now() |> Timex.shift([seconds: 2])}
    {:ok, pid} = PhotoSupervisor.spawn_photo(picture)
    Process.sleep(2_000)

    assert Process.alive?(pid) == false
  end

  test "pictures are started with their current score" do
    {user, _category, picture} = new_picture()
    {:ok, vote} = Db.vote_on_picture(%{picture_id: picture.id, user_id: user.id, value: 1})
    pid = Photo.get(picture.id)
    score = Photo.get_score(pid)

    assert score == vote.value
  end

  defp picture_params(params) do
    %{
      title: "title",
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

  defp user() do
    import Ecto.Query
    Db.Repo.one(from u in Db.User, limit: 1)
  end

  defp category() do
    import Ecto.Query
    Db.Repo.one(from c in Db.Category, limit: 1)
  end

  defp new_picture(picture_params \\ %{}) do
    user = user()
    category = category()
    {:ok, picture} =
      %{user_id: user.id, category_id: category.id}
      |> Map.merge(picture_params)
      |> picture_params()
      |> Db.new_picture()
    {user, category, picture}
  end

  defp kill(pid) do
    GenServer.stop(pid)
  end

  defp delete_all_pictures do
    Db.Repo.delete_all(Db.Picture)
  end
end
