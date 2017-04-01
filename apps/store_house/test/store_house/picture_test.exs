defmodule StoreHouse.PictureTest do
  alias StoreHouse.Picture
  use ExUnit.Case
  require Picture
  @title "title"
  @location {45, 100}
  @hash "abc"

  describe "new/6" do
    test "correct params set correctly" do
      {_u, uk} = TestUtils.user()
      {_c, ck} = TestUtils.category()
      {_a, ak} = TestUtils.application()
      {:ok, pic} = Picture.new(@title, @location, @hash, uk, ck, ak)

      assert Picture.picture(pic, :key) !== :undefined
      assert Picture.picture(pic, :title) === @title
      assert Picture.picture(pic, :location) === @location
      assert Picture.picture(pic, :hash) === @hash
      assert Picture.picture(pic, :user_key) === uk
      assert Picture.picture(pic, :category_key) !== :undefined
      assert Picture.picture(pic, :application_key) !== :undefined
      assert Picture.picture(pic, :updated_at) !== :undefined
      assert Picture.picture(pic, :inserted_at) !== :undefined
    end

    test "invalid coordinate returns error" do
      {_u, uk} = TestUtils.user()
      {_c, ck} = TestUtils.category()
      {_a, ak} = TestUtils.application()

      assert {:error, :invalid_location} = Picture.new(@title, {-300, 300}, @hash, uk, ck, ak)
    end
  end

  describe "set_paths/3" do
    test "correctly sets paths" do
      {_u, uk} = TestUtils.user()
      {_c, ck} = TestUtils.category()
      {_a, ak} = TestUtils.application()
      {:ok, pic} = Picture.new(@title, @location, @hash, uk, ck, ak)
      p = "/path/to/pic"
      t = "/path/to/thumbnail"
      Process.sleep(50)
      pic2 = Picture.set_paths(pic, p, t)

      assert Picture.picture(pic2, :picture_path) === p
      assert Picture.picture(pic2, :thumbnail_path) === t
      assert Picture.picture(pic, :updated_at) < Picture.picture(pic2, :updated_at)
    end
  end
end
