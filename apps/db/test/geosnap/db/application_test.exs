defmodule Geosnap.Db.ApplicationTest do
  use ExUnit.Case
  alias Geosnap.Db.Application

  test "valid new changeset" do
    changeset = Application.new_changeset("test_name", "email@test.com")
    IO.inspect changeset
    assert changeset.valid? == true
  end
end
