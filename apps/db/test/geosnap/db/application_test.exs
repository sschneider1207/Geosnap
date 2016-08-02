defmodule Geosnap.Db.ApplicationTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.Application

  test "valid new changeset" do
    changeset = Application.new_changeset("test_name", "email@test.com")
    assert changeset.valid? == true
  end

  test "invalid email is an invalid changeset" do
    changeset = Application.new_changeset("test_name", "email@te st.com")
    assert changeset.valid? == false
  end
end
