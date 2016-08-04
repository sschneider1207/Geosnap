defmodule Geosnap.Db.UserTest do
  use ExUnit.Case
  alias Geosnap.Db.{User, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "new changeset hashes password correctly" do
    params = %{username: "username", password: "password123", email: "email@test.com"}
    changeset = User.new_changeset(params)
    match = Geosnap.Encryption.check_password("password123", changeset.changes.hashed_password)
    
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

  test "valid new user inserts ok" do
    params = %{username: "username", password: "password123", email: "email@test.com"}
    {:ok, user} =
      User.new_changeset(params)
      |> Repo.insert()

    assert user.username == "username"
    assert user.email == "email@test.com"
  end

  test "cannot insert duplicate username" do
    params1 = %{username: "username", password: "password123", email: "email@test.com"}
    {:ok, user} =
      User.new_changeset(params1)
      |> Repo.insert()

    params2 = %{username: user.username, password: "password123", email: "email2@test.com"}
    {:error, changeset} =
      User.new_changeset(params2)
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:username] == {"has already been taken", []}
  end

  test "cannot insert duplicate email" do
    params1 = %{username: "username", password: "password123", email: "email@test.com"}
    {:ok, user} =
      User.new_changeset(params1)
      |> Repo.insert()
    
    params2 = %{username: "username1", password: "password123", email: user.email}
    {:error, changeset} =
      User.new_changeset(params2)
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:email] == {"has already been taken", []}
  end
end
