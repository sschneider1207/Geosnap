defmodule Geosnap.Db.CategoryTest do
  use ExUnit.Case, async: true
  alias Geosnap.Db.{Category, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "no name isn't a valid changeset" do
    changeset = Category.new_changeset(nil)

    assert changeset.valid? == false
  end

  test "whitespace name isn't a valid changeset" do
    changeset = Category.new_changeset("   ")

    assert changeset.valid? == false
  end

  test "any name can be inserted" do
    {:ok, category} =
        Category.new_changeset("nature")
        |> Repo.insert()

    assert category.name == "nature"
  end

  test "duplicate category can't be inserted" do
    {:ok, category} =
      Category.new_changeset("nature")
      |> Repo.insert()
    {:error, changeset} =
      Category.new_changeset(category.name)
      |> Repo.insert()

    assert changeset.valid? == false
    assert changeset.errors[:name] == {"has already been taken", []}
  end
end
