defmodule Geosnap.Db.ApplicationTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.Application

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
end
