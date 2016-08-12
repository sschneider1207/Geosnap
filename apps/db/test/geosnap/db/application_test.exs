defmodule Geosnap.Db.ApplicationTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{Application, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "valid new changeset" do
    params = %{name: "test_name", email: "email@test.com"}
    changeset = Application.new_changeset(params)
    assert changeset.valid? == true
  end

  test "invalid email is an invalid changeset" do
    params = %{name: "test_name", email: "email@te st.com"}
    changeset = Application.new_changeset(params)
    assert changeset.valid? == false
  end

  test "verify email changeset correctly flips status" do
    {:ok, app} = new_application()
    changeset = Application.verify_email_changeset(app)

    assert changeset.valid? == true
    assert changeset.changes.verified_email == true
  end

  test "verify confirmed change email changeset is valid" do
    {:ok, app} = new_application()
    {:ok, verified_app} =
      Application.verify_email_changeset(app)
      |> Repo.update()
    params = %{email: "email2@test.com", email_confirmation: "email2@test.com"}
    changeset = Application.change_email_changeset(verified_app, params)

    assert changeset.valid? == true
    assert changeset.changes.verified_email == false
  end

  test "verify unconfirmed change email changeset isn't valid" do
    {:ok, app} = new_application()
    params = %{email: "email2@test.com", email_confirmation: "email@test.com"}
    changeset = Application.change_email_changeset(app, params)

    assert changeset.valid? == false
  end

  defp new_application(params \\ %{}) do
    %{
      name: "test_name",
      email: "email@test.com"
    }
    |> Map.merge(params)
    |> Application.new_changeset()
    |> Repo.insert()
  end
end
