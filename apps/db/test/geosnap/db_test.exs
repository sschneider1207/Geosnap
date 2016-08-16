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

  test "can create application with ok params" do
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

  test "can change application email with ok params" do
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
end
