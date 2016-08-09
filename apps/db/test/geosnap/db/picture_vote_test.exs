defmodule Geosnap.Db.PictureVoteTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{PictureVote, User, Picture, Category, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "value must not be greater than 1 for new changeset to be valid" do
    changeset = PictureVote.new_changeset(%{user_id: 1, picture_id: 1, value: 2})

    assert changeset.valid? == false
  end

  test "value must not be less than -1 for new changeset to be valid" do
    changeset = PictureVote.new_changeset(%{user_id: 1, picture_id: 1, value: -2})

    assert changeset.valid? == false
  end

  test "picture must exist for new changeset to be valid" do
    {:ok, user} =
      %{username: "user", password: "1234567890", email: "e@t.com"}
      |> User.new_changeset()
      |> Repo.insert()

    {:error, changeset} =
      %{user_id: user.id, picture_id: 0, value: 1}
      |> PictureVote.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "user must exist for new changeset to be valid" do
    {:ok, category} =
      Category.new_changeset("cat")
      |> Repo.insert()

    {:ok, user} =
      %{username: "user", password: "1234567890", email: "e@t.com"}
      |> User.new_changeset()
      |> Repo.insert()

    {:ok, picture} =
      picture_params(user.id, category.id)
      |> Picture.new_changeset()
      |> Repo.insert()

    {:error, changeset} =
      %{user_id: user.id + 1, picture_id: picture.id, value: 1}
      |> PictureVote.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "valid new vote inserts okay" do
    {:ok, category} =
      Category.new_changeset("cat")
      |> Repo.insert()

    {:ok, user} =
      %{username: "user", password: "1234567890", email: "e@t.com"}
      |> User.new_changeset()
      |> Repo.insert()

    {:ok, picture} =
      picture_params(user.id, category.id)
      |> Picture.new_changeset()
      |> Repo.insert()

    result =
      %{user_id: user.id, picture_id: picture.id, value: 1}
      |> PictureVote.new_changeset()
      |> Repo.insert()

    assert {:ok, _vote} = result
  end

  test "value must not be greater than 1 for update changeset to be valid" do
    changeset = PictureVote.update_vote_changeset(%PictureVote{}, 2)

    assert changeset.valid? == false
  end

  test "value must not be less than -1 for update changeset to be valid" do
    changeset = PictureVote.update_vote_changeset(%PictureVote{}, -2)

    assert changeset.valid? == false
  end

  defp picture_params(user_id, category_id) do
    %{
      title: "title",
      location: %Geo.Point{coordinates: {0,0}, srid: 4326},
      expiration: Timex.now() |> Timex.shift([hours: 1]),
      md5: "abc",
      picture_path: "/p/t/p",
      thumbnail_path: "/p/t/t",
      user_id: user_id,
      category_id: category_id
    }
  end
end
