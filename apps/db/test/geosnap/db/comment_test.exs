defmodule Geosnap.Db.CommentTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{Comment, Picture, Repo, Category, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "negative depth on a new changeset is not valid" do
    changeset =
      params(%{depth: -1})
      |> Comment.new_changeset()

    assert changeset.valid? == false
  end

  test "depth and parent comment id is not required for a new changeset" do
    changeset =
      params()
      |> Comment.new_changeset()

    assert changeset.valid? == true
  end

  test "picture must exist for new changeset" do
    {:ok, user} = new_user()

    {:error, changeset} =
      params(%{user_id: user.id})
      |> Comment.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "user must exist for a new changeset" do
    {:ok, user} = new_user()
    {:ok, category} =
      Category.new_changeset("nature")
      |> Repo.insert()
    {:ok, picture} = new_picture(user.id, category.id)

    {:error, changeset} =
      params(%{user_id: user.id + 1, picture_id: picture.id})
      |> Comment.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "valid changeset inserts okay" do
    {:ok, user} = new_user()
    {:ok, category} =
      Category.new_changeset("nature")
      |> Repo.insert()
    {:ok, picture} = new_picture(user.id, category.id)

    result =
      params(%{user_id: user.id, picture_id: picture.id})
      |> Comment.new_changeset()
      |> Repo.insert()

    assert {:ok, _comment} = result
  end

  test "parent comment must exist if provided for a new changeset" do
    {:ok, user} = new_user()
    {:ok, category} =
      Category.new_changeset("nature")
      |> Repo.insert()
    {:ok, picture} = new_picture(user.id, category.id)

    {:error, changeset} =
      params(%{user_id: user.id, picture_id: picture.id, parent_comment_id: 1})
      |> Comment.new_changeset()
      |> Repo.insert()

    assert changeset.valid? == false
  end

  test "if parent comment does exist new changeset can insert" do
    {:ok, user} = new_user()
    {:ok, category} =
      Category.new_changeset("nature")
      |> Repo.insert()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, comment} =
      params(%{user_id: user.id, picture_id: picture.id})
      |> Comment.new_changeset()
      |> Repo.insert()

    result =
      params(%{user_id: user.id, picture_id: picture.id, parent_comment_id: comment.id})
      |> Comment.new_changeset()
      |> Repo.insert()

    assert {:ok, _comment} = result
  end

  test "delete comment changeset sets text to <deleted>" do
    {:ok, user} = new_user()
    {:ok, category} =
      Category.new_changeset("nature")
      |> Repo.insert()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, comment} =
      params(%{user_id: user.id, picture_id: picture.id})
      |> Comment.new_changeset()
      |> Repo.insert()

    changeset = Comment.delete_changeset(comment)

    assert changeset.valid? == true
    assert changeset.changes.text =~ "<deleted>"
  end

  def params(params \\ %{}) do
    %{
      user_id: 1,
      picture_id: 1,
      text: "text"
    }
    |> Map.merge(params)
  end

  def new_user(params \\ %{}) do
    %{
      username: "test_user",
      password: "test_password",
      email: "test@example.com"
    }
    |> Map.merge(params)
    |> User.new_changeset()
    |> Repo.insert()
  end

  defp new_picture(user_id, category_id) do
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
    |> Picture.new_changeset()
    |> Repo.insert()
  end
end
