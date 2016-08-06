defmodule Geosnap.Db.UserTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{User, Repo}
  alias Geosnap.Encryption

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "new changeset hashes password correctly" do
    params = %{username: "username", password: "password123", email: "email@test.com"}
    changeset = User.new_changeset(params)
    match = Encryption.check_password("password123", changeset.changes.hashed_password)
    
    assert match == true
  end

  test "new changeset with short password is not valid" do
    params = %{username: "username", password: "password", email: "email@test.com"}
    changeset = User.new_changeset(params)
    
    assert changeset.valid? == false
    assert {reason, _} = changeset.errors[:password]
    assert reason =~ "should be at least %{count} character(s)"
  end

  test "new changeset with invalid email is not valid" do
    params = %{username: "username", password: "password123", email: "email@te st.com"}
    changeset = User.new_changeset(params)

    assert changeset.valid? == false
  end

  test "new user starts with unverified email" do
    {:ok, user} = new_user()
    
    assert user.verified_email == false
  end

  test "cannot insert duplicate username" do
    {:ok, user} = new_user()
    params = %{username: user.username, password: "password123", email: "email2@test.com"}
    {:error, changeset} = new_user(params)

    assert changeset.valid? == false
    assert changeset.errors[:username] == {"has already been taken", []}
  end

  test "cannot insert duplicate email" do
    {:ok, user} = new_user()
    params = %{username: "username1", password: "password123", email: user.email}
    {:error, changeset} = new_user(params)

    assert changeset.valid? == false
    assert changeset.errors[:email] == {"has already been taken", []}
  end

  test "verify user changeset is valid" do
    {:ok, user} = new_user()
    changeset = User.verify_email_changeset(user)

    assert changeset.valid? == true
  end

  test "verify confirmed change password changeset is valid" do
    {:ok, user} = new_user()
    params = %{password: "password321", password_confirmation: "password321"}
    changeset = User.change_password_changeset(user, params) 
    
    assert changeset.valid? == true
    match = Encryption.check_password("password321", changeset.changes.hashed_password)
    assert match == true
  end

  test "verify unconfirmed change password changeset isn't valid" do
    {:ok, user} = new_user()
    params = %{password: "password321", password_confirmation: "password123"}
    changeset = User.change_password_changeset(user, params) 
    
    assert changeset.valid? == false
  end

  test "verify confirmed change email changeset is valid" do
    {:ok, user} = new_user()
    {:ok, verified_user} = 
      User.verify_email_changeset(user)
      |> Repo.update()
    params = %{email: "email2@test.com", email_confirmation: "email2@test.com"}
    changeset = User.change_email_changeset(verified_user, params) 
    
    assert changeset.valid? == true
    assert changeset.changes.verified_email == false
  end

  test "verify unconfirmed change email changeset isn't valid" do
    {:ok, user} = new_user()
    params = %{email: "email2@test.com", email_confirmation: "email@test.com"}
    changeset = User.change_email_changeset(user, params) 
    
    assert changeset.valid? == false
  end

  test "update permissions changeset isn't valid with negative number" do
    {:ok, user} = new_user()
    changeset = User.update_permissions(user, -1)

    assert changeset.valid? == false
  end

  test "update permissions changeset is valid with positive number" do
    {:ok, user} = new_user()
    changeset = User.update_permissions(user, 4)

    assert changeset.valid? == true
  end

  test "update permissions changeset isn't valid with nil" do
    {:ok, user} = new_user()
    changeset = User.update_permissions(user, nil)

    assert changeset.valid? == false
  end

  defp new_user(params \\ %{}) do
    %{
      username: "username",
      password: "password123",
      email: "email@test.com"
    } 
    |> Map.merge(params)
    |> User.new_changeset()
    |> Repo.insert()
  end
end
