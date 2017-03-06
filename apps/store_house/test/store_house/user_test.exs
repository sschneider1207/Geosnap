defmodule StoreHouse.UserTest do
  use ExUnit.Case
  alias StoreHouse.{User, Utils}
  alias Geosnap.Encryption
  require User
  @username "user"
  @password "password123"
  @email "nsa@whitehouse.com"

  describe "new/3" do
    test "invalid email is rejected" do
      assert User.new(@username, @password, "email") === {:error, :invalid_email}
    end

    test "too short password is rejected" do
      assert User.new(@username, "pass", @email) === {:error, :password_too_short}
    end

    test "all fields are correctly set" do
      now = Utils.timestamp()
      {:ok, u} = User.new(@username, @password, @email)
      hashed_password = User.user(u, :hashed_password)

      assert User.user(u, :key) === @username
      assert Encryption.check_password(@password, hashed_password) === true
      assert User.user(u, :email) === @email
      assert User.user(u, :inserted_at) > now
      assert User.user(u, :updated_at) > now
    end
  end

  describe "verify_email/1" do
    test "correctly toggles field" do
      {:ok, u} = User.new(@username, @password, @email)
      {:ok, u2} = User.verify_email(u)

      assert User.user(u2, :verified_email) === true
    end

    test "can't verify twice" do
      {:ok, u} = User.new(@username, @password, @email)
      {:ok, u2} = User.verify_email(u)

      assert User.verify_email(u2) === {:error, :already_verified}
    end
  end

  describe "change_email/2" do
    test "can't change to an invalid email" do
      {:ok, app} = User.new(@username, @password, @email)

      assert User.change_email(app, "email") === {:error, :invalid_email}
    end

    test "change resets verified_email" do
      {:ok, u} = User.new(@username, @password, @email)
      {:ok, u2} = User.verify_email(u)
      new_email = "notaspy@cia.gov"
      {:ok, u3} = User.change_email(u2, new_email)

      assert User.user(u3, :email) === new_email
      assert User.user(u3, :verified_email) === false
    end
  end

  describe "change_password/2" do
    test "can't use too short password" do
      {:ok, u} = User.new(@username, @password, @email)

      assert User.change_password(u, "pass") === {:error, :password_too_short}
    end

    test "can use new password after changing" do
      {:ok, u} = User.new(@username, @password, @email)
      new_pass = "newpassword123"
      {:ok, u2} = User.change_password(u, new_pass)
      hashed_password = User.user(u2, :hashed_password)

      assert Encryption.check_password(new_pass, hashed_password) === true
    end
  end

  describe "change_permissions/2" do
    test "can't set permissions negative" do
      {:ok, u} = User.new(@username, @password, @email)

      assert User.change_permissions(u, -1) === {:error, :invalid_permissions}
    end

    test "set updates field" do
      {:ok, u} = User.new(@username, @password, @email)
      new_perms = 10
      {:ok, u2} = User.change_permissions(u, new_perms)

      assert User.user(u2, :permissions) === new_perms
    end
  end
end
