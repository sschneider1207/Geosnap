defmodule Geosnap.Db.ApiKeyTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{ApiKey, Application, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "public/private keys are generated in new changeset" do
    changeset = ApiKey.new_changeset(1)
    assert changeset.valid? == true
    assert changeset.changes.public_key != nil
    assert changeset.changes.private_key != nil
  end

  test "doesn't insert if application doesn't exist" do
    {:error, changeset} =
      ApiKey.new_changeset(1)
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:application_id] == {"does not exist", []}
  end

  test "inserts okay if application does exist" do
    {:ok, app} = 
      Application.new_changeset("test_app", "email@test.com")
      |> Repo.insert()

    {:ok, api_key} =
      ApiKey.new_changeset(app.id)
      |> Repo.insert()

    assert api_key.application_id == app.id
  end

  test "applications can't get a second api key" do
    {:ok, app} = 
      Application.new_changeset("test_app", "email@test.com")
      |> Repo.insert()

    {:ok, api_key} =
      ApiKey.new_changeset(app.id)
      |> Repo.insert()
    
    {:error, changeset} = 
      ApiKey.new_changeset(app.id)
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:application_id] == {"has already been taken", []}
  end
end
