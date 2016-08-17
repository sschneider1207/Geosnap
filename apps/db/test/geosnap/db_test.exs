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
end
