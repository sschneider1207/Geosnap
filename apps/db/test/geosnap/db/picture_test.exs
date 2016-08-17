defmodule Geosnap.Db.PictureTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{Picture, Repo, Category, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "title is required for new changeset" do
    changeset =
      params(%{title: nil})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "location is required for new changeset" do
    changeset =
      params(%{location: nil})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "expiration is required for new changeset" do
    changeset =
      params(%{expiration: nil})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "picture_path is required for new changeset" do
    changeset =
      params(%{picture_path: nil})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "thumbnail_path is required for new changeset" do
    changeset =
      params(%{thumbnail_path: nil})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "md5 is required for new changeset" do
    changeset =
      params(%{md5: nil})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "location must be a valid coordinate for new changeset" do
    changeset =
      params(%{location: %Geo.Point{coordinates: {190.0, 76.0}, srid: 4326}})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "location must have correct srid for new changeset" do
    changeset =
      params(%{location: %Geo.Point{coordinates: {120, 45}, srid: 0000}})
      |> Picture.new_changeset()

    assert changeset.valid? == false
  end

  test "category must exist for new changeset" do
    {:ok, user} =
      %{
        username: "username",
        password: "password123",
        email: "email@test.com",
      }
      |> User.new_changeset()
      |> Repo.insert()

    {:error, changeset} =
      params(%{user_id: user.id})
      |> Picture.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "user must exist for new changeset" do
    {:ok, category} =
      Category.new_changeset("category")
      |> Repo.insert()

    {:error, changeset} =
      params(%{category_id: category.id})
      |> Picture.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "valid new changeset inserts okay" do
    {:ok, category} =
      Category.new_changeset("category")
      |> Repo.insert()

    {:ok, user} =
      %{
        username: "username",
        password: "password123",
        email: "email@test.com",
      }
      |> User.new_changeset()
      |> Repo.insert()

    result =
      params(%{category_id: category.id, user_id: user.id})
      |> Picture.new_changeset()
      |> Repo.insert()

    assert {:ok, _user} = result
  end

  defp params(params) do
    %{
      title: "title",
      location: %Geo.Point{
        coordinates: {120,-60},
        srid: 4326
      },
      expiration: Timex.now() |> Timex.shift([hours: 1]),
      picture_path: "/path/to/pic",
      thumbnail_path: "/path/to/thumbnail",
      md5: "abcdefghijklmnopqrstuvwxyz",
      user_id: 2324,
      category_id: 1
    }
    |> Map.merge(params)
  end
end
