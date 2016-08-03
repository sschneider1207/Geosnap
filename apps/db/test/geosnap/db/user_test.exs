defmodule Geosnap.Db.UserTest do
  use ExUnit.Case
  alias Geosnap.Db.{User, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "new changeset hashes password correctly" do
    changeset = User.new_changeset("username", "password123", "email@test.com")  
    match = Geosnap.Encryption.check_password("password123", changeset.changes.hashed_password)
    
    assert match == true
  end

  test "new changeset with short password is not valid" do
    changeset = User.new_changeset("username", "123456789", "email@test.com")
    
    assert changeset.valid? == false
    assert {reason, _} = changeset.errors[:password]
    assert reason =~ "should be at least %{count} character(s)"
  end

  test "new changeset with invalid email is not valid" do
    changeset = User.new_changeset("username", "password123", "email@te st.com")

    assert changeset.valid? == false
  end

  test "valid new user inserts ok" do
    {:ok, user} =
      User.new_changeset("username", "password123", "email@test.com")
      |> Repo.insert()

    assert user.username == "username"
    assert user.email == "email@test.com"
  end

  test "cannot insert duplicate username" do
    {:ok, user} =
      User.new_changeset("username", "password123", "email@test.com")
      |> Repo.insert()

    {:error, changeset} =
      User.new_changeset(user.username, "password123", "email2@test.com")
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:username] == {"has already been taken", []}
  end

  test "cannot insert duplicate email" do
    {:ok, user} =
      User.new_changeset("username", "password123", "email@test.com")
      |> Repo.insert()

    {:error, changeset} =
      User.new_changeset("username2", "password123", user.email)
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:email] == {"has already been taken", []}
  end
end
