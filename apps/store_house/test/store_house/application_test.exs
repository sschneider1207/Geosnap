defmodule StoreHouse.ApplicationTest do
  use ExUnit.Case
  alias StoreHouse.{Application, Utils}
  require Application
  @email "email@nsa.gov"
  @name "name"

  describe "new/2" do
    test "invalid email is rejected" do
      assert Application.new("name", "bad email") === {:error, :invalid_email}
    end

    test "new row has correct fields" do
      now = Utils.timestamp()
      {:ok, app} = Application.new(@name, @email)

      assert Application.application(app, :key) !== :undefined
      assert Application.application(app, :name) === @name
      assert Application.application(app, :email) === @email
      assert Application.application(app, :verified_email) === false
      assert Application.application(app, :inserted_at) > now
      assert Application.application(app, :updated_at) > now
    end

  end

  describe "verify_email/1" do
    test "correctly toggles field" do
      {:ok, app} = Application.new(@name, @email)
      {:ok, app2} = Application.verify_email(app)

      assert Application.application(app2, :verified_email) === true
    end

    test "can't verify twice" do
      {:ok, app} = Application.new(@name, @email)
      {:ok, app2} = Application.verify_email(app)

      assert Application.verify_email(app2) === {:error, :already_verified}
    end
  end

  describe "change_email/2" do
    test "can't change to an invalid email" do
      {:ok, app} = Application.new(@name, @email)

      assert Application.change_email(app, "email") === {:error, :invalid_email}
    end

    test "change resets verified_email" do
      {:ok, app} = Application.new(@name, @email)
      {:ok, app2} = Application.verify_email(app)
      new_email = "notaspy@cia.gov"
      {:ok, app3} = Application.change_email(app2, new_email)

      assert Application.application(app3, :email) === new_email
      assert Application.application(app3, :verified_email) === false
    end
  end
end
