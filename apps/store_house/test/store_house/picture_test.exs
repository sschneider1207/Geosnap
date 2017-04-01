defmodule StoreHouse.PictureTest do
  alias StoreHouse.{Picture, Utils}
  use ExUnit.Case
  require Picture
  @title "title"
  @location {45, 100}
  @hash "abc"

  describe "new/6" do
    test "correct params set correctly" do
      {u, uk} = TestUtils.user()
      {c, ck} = TestUtils.category()
      {a, ak} = TestUtils.application()
      {:ok, pic} = Picture.new(@title, @location, @hash, uk, ck, ak)

      assert Picture.picture(pic, :key) !== :undefined
      assert Picture.picture(pic, :title) === @title
      assert Picture.picture(pic, :location) == @location
      assert Picture.picture(pic, :hash) == @hash
      assert Picture.picture(pic, :user_key) === uk
      assert Picture.picture(pic, :category_key) !== :undefined
      assert Picture.picture(pic, :application_key) !== :undefined
      assert Picture.picture(pic, :updated_at) !== :undefined
      assert Picture.picture(pic, :inserted_at) !== :undefined
    end
  end
end
