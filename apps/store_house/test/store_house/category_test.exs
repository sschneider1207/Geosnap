defmodule StoreHouse.CategoryTest do
  use ExUnit.Case
  alias StoreHouse.{Category, Utils}
  require Category
  @name :nature
  @color "green"

  test "new categories get their fields set correctly" do
    now = Utils.timestamp()
    Process.sleep(10) # 2fast3me
    cat = Category.new(@name, @color)

    assert Category.category(cat, :key) === @name
    assert Category.category(cat, :color) === @color
    assert Category.category(cat, :inserted_at) > now
    assert Category.category(cat, :updated_at) > now
  end

  describe "change_key/2" do
    test "can't change to the same key" do
      cat = Category.new(@name, @color)

      assert Category.change_key(cat, @name) === {:error, :key_unchanged}
    end

    test "change updates key" do
      cat = Category.new(@name, @color)
      new_name = :events
      {:ok, cat2} = Category.change_key(cat, new_name)

      assert Category.category(cat2, :key) === new_name
    end
  end

  describe "change_color/2" do
    test "can't change to the same color" do
      cat = Category.new(@name, @color)

      assert Category.change_color(cat, @color) === {:error, :color_unchanged}
    end

    test "change updates key" do
      cat = Category.new(@name, @color)
      new_color = {235, 100, 70}
      {:ok, cat2} = Category.change_color(cat, new_color)

      assert Category.category(cat2, :color) === new_color
    end
  end
end
