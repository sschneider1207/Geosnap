defmodule Geosnap.DbTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Db.Repo)
  end

  test "can't create application with bad email" do
    {:error, errors} = Db.new_application(%{name: "test", email: "test.com"})

    assert Map.has_key?(errors, :email)
  end

  test "can create application with valid params" do
    name = "test"
    email = "test@example.com"
    {:ok, application} = Db.new_application(%{name: name, email: email})

    assert application.name == name
    assert application.email == email
    assert application.api_key.public_key != nil
    assert application.api_key.private_key != nil
  end

  test "can't change application email with bad params" do
    {:ok, application} = Db.new_application(%{name: "test", email: "test@example.com"})
    new_email = "test2example.com"
    {:error, errors} = Db.change_application_email(application, %{email: new_email, email_confirmation: new_email})

    assert Map.has_key?(errors, :email)
  end

  test "can change application email with valid params" do
    {:ok, application} = Db.new_application(%{name: "test", email: "test@example.com"})
    new_email = "test2@example.com"
    {:ok, application} = Db.change_application_email(application, %{email: new_email, email_confirmation: new_email})

    assert application.email == new_email
  end

  test "rotate application key works" do
    {:ok, application} = Db.new_application(%{name: "test", email: "test@example.com"})
    {:ok, new_application} = Db.rotate_application_key(application)

    assert new_application.api_key.public_key != application.api_key.public_key
    assert new_application.api_key.private_key != nil
    assert new_application.api_key.private_key != application.api_key.private_key
  end

  test "get application with legit key works" do
    {:ok, application} = Db.new_application(%{name: "test", email: "test@example.com"})
    application2 = Db.get_application(application.api_key.public_key)

    assert application.id == application2.id
  end

  test "get application with bad key returns nil" do
    application = Db.get_application("not a public key")

    assert application == nil
  end

  test "can create new user with valid params" do
    username = "user"
    password = "password123"
    email = "test@example.com"
    {:ok, user} = Db.new_user(%{username: username, password: password, email: email})

    assert user.username == username
    assert user.email == email
    assert Geosnap.Encryption.check_password(password, user.hashed_password)
  end

  test "can't create new user with bad params" do
    username = "user"
    password = "short"
    email = "test@example.com"
    {:error, errors} = Db.new_user(%{username: username, password: password, email: email})

    assert Map.has_key?(errors, :password)
  end

  test "can't change user password with bad params" do
    {:ok, user} = Db.new_user(%{username: "user", password: "password123", email: "e@mail.com"})
    {:error, errors} = Db.change_user_password(user, %{password: "password321", password_confirmation: "password123"})

    assert Map.has_key?(errors, :password_confirmation)
  end

  test "can change user password with valid params" do
    {:ok, user} = Db.new_user(%{username: "user", password: "password123", email: "e@mail.com"})
    new_password = "password321"
    {:ok, user} = Db.change_user_password(user, %{password: new_password, password_confirmation: new_password})

    assert Geosnap.Encryption.check_password(new_password, user.hashed_password)
  end

  test "can't change user email with bad params" do
    {:ok, user} = Db.new_user(%{username: "user", password: "password123", email: "e@mail.com"})
    {:error, errors} = Db.change_user_email(user, %{email: "g@mail.com", email_confirmation: "a@mail.com"})

    assert Map.has_key?(errors, :email_confirmation)
  end

  test "can change user email with valid params" do
    {:ok, user} = Db.new_user(%{username: "user", password: "password23", email: "e@mail.com"})
    new_email = "g@mail.com"
    {:ok, user} = Db.change_user_email(user, %{email: new_email, email_confirmation: new_email})

    assert user.email == new_email
  end

  test "get user with legit params" do
    {:ok, user} = Db.new_user(%{username: "user", password: "password23", email: "e@mail.com"})
    user2 = Db.get_user(user.id)
    user3 = Db.get_user(user.username)

    assert user.id == user2.id
    assert user.id == user3.id
  end

  test "get user with bad params returns nil" do
    user = Db.get_user("TheWalkinMan")
    user2 = Db.get_user(1)

    assert user == nil
    assert user2 == nil
  end

  test "can't create new picture with bad params" do
    {:error, errors} = Db.new_picture(%{location: %Geo.Point{coordinates: {300, 300}, srid: 4236}})

    assert Map.has_key?(errors, :location)
  end

  test "can create new picture with valid params" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    params = %{
      title: "test pic",
      user_id: user.id,
      category_id: category.id,
      expiration: Timex.now() |> Timex.shift(hours: 1),
      location: %Geo.Point{coordinates: {0,0}, srid: 4326},
      md5: "123",
      picture_path: "/p",
      thumbnail_path: "/t"
    }
    {:ok, picture} = Db.new_picture(params)

    assert picture.title == params.title
    assert picture.user_id == params.user_id
    assert picture.category_id == params.category_id
    assert picture.expiration == params.expiration
    assert picture.location == params.location
    assert picture.md5 == params.md5
    assert picture.picture_path == params.picture_path
    assert picture.thumbnail_path == params.thumbnail_path
  end

  test "can delete existing picture" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    result = Db.delete_picture(picture)

    assert :ok = result
  end

  test "can't delete non existant picture" do
    assert_raise(
      Ecto.StaleEntryError,
      fn -> Db.delete_picture(%Db.Picture{id: 1}) end
      )
  end

  test "can get pictures near a point" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {lng, lat} = picture.location.coordinates
    pictures = Db.get_pictures(lng, lat)

    assert length(pictures) == 1
    assert hd(pictures).id == picture.id
  end

  test "can't get a picture if it's too far away" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {lng, lat} = picture.location.coordinates
    pictures = Db.get_pictures(lng * -1, lat * -1)

    assert [] = pictures
  end

  test "get picture with non existant id returns nil" do
    picture = Db.get_picture(1)

    assert is_nil(picture) == true
  end

  test "can get picture with legit id" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    picture2 = Db.get_picture(picture.id)

    assert picture.id == picture2.id
  end

  test "can get pictures and loaded comments with legit id" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, comment} = Db.new_comment(%{user_id: user.id, picture_id: picture.id, text: "sop"})
    picture2 = Db.get_picture(picture.id, true)

    assert picture2.id == picture.id
    assert length(picture2.comments) == 1
    assert hd(picture2.comments).id == comment.id
  end

  test "can create vote on a picture if one doesn't exist" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, vote} = Db.vote_on_picture(%{user_id: user.id, picture_id: picture.id, value: 1})

    assert vote.user_id == user.id
    assert vote.picture_id == picture.id
    assert vote.value == 1
  end

  test "can't vote on the same picture twice" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, _vote} = Db.vote_on_picture(%{user_id: user.id, picture_id: picture.id, value: 1})
    {:error, errors} = Db.vote_on_picture(%{user_id: user.id, picture_id: picture.id, value: 1})

    assert Map.has_key?(errors, :picture)
  end

  test "can't vote on non existant picture" do
    {:ok, user} = new_user()
    {:error, errors} = Db.vote_on_picture(%{user_id: user.id, picture_id: 1, value: 1})

    assert Map.has_key?(errors, :picture)
  end

  test "can update existing vote" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, vote} = Db.vote_on_picture(%{user_id: user.id, picture_id: picture.id, value: 1})
    {:ok, vote2} = Db.update_vote_on_picture(vote, -1)

    assert vote.id == vote2.id
    assert vote.value != vote2.value
    assert vote2.value == -1
  end

  test "can't update non existant vote" do
    assert_raise(
      Ecto.StaleEntryError,
      fn -> Db.update_vote_on_picture(%Db.PictureVote{id: 1}, 1) end
    )
  end

  test "can delete existing vote" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, vote} = Db.vote_on_picture(%{user_id: user.id, picture_id: picture.id, value: 1})
    result = Db.delete_picture_vote(vote)

    assert :ok = result
  end

  test "can't delete non existant vote" do
    assert_raise(
      Ecto.StaleEntryError,
      fn -> Db.delete_picture_vote(%Db.PictureVote{id: 1}) end
    )
  end

  test "can create a new comment with valid params" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, comment} = Db.new_comment(%{user_id: user.id, picture_id: picture.id, text: "sop"})

    assert comment.user_id == user.id
    assert comment.picture_id == picture.id
  end

  test "can't create a new comment with bad params" do
    {:error, errors} = Db.new_comment(%{user_id: 1, picture_id: 1, text: "sop"})

    assert Map.has_key?(errors, :user)
  end

  test "can mark existing comment as deleted" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, comment} = Db.new_comment(%{user_id: user.id, picture_id: picture.id, text: "sop"})
    {:ok, deleted} = Db.mark_comment_as_deleted(comment)

    assert deleted.id == comment.id
    assert deleted.text =~ "<deleted>"
  end

  test "can't mark non existant comment as deleted" do
    assert_raise(
      Ecto.StaleEntryError,
      fn -> Db.mark_comment_as_deleted(%Db.Comment{id: 1}) end
    )
  end

  test "can delete existing comment" do
    {:ok, user} = new_user()
    {:ok, category} = new_category()
    {:ok, picture} = new_picture(user.id, category.id)
    {:ok, comment} = Db.new_comment(%{user_id: user.id, picture_id: picture.id, text: "sop"})
    result = Db.delete_comment(comment)

    assert :ok = result
  end

  test "can't delete non existant comment" do
    assert_raise(
      Ecto.StaleEntryError,
      fn -> Db.delete_comment(%Db.Comment{id: 1}) end
    )
  end

  def new_user(params \\ %{}) do
    %{
      username: "user",
      password: "password23",
      email: "test@example.com"
    }
    |> Map.merge(params)
    |> Db.new_user()
  end

  def new_category(name \\ "nature") do
    Db.Category.new_changeset(name)
    |> Db.Repo.insert()
  end

  def new_picture(user_id, category_id, params \\ %{}) do
    %{
      title: "test pic",
      user_id: user_id,
      category_id: category_id,
      expiration: Timex.now() |> Timex.shift(hours: 1),
      location: %Geo.Point{coordinates: {80.0,40.0}, srid: 4326},
      md5: "123",
      picture_path: "/p",
      thumbnail_path: "/t"
    }
    |> Map.merge(params)
    |> Db.new_picture()
  end
end
