defmodule StoreHouse.CommentTest do
  use ExUnit.Case
  alias StoreHouse.Comment
  require Comment

  describe "new/5" do
    test "fields are set correctly" do
      text = "Did you ever hear the tragedy of Darth Plagueis The Wise?"
      user_key = "Palpatine"
      picture_key = "Senate"
      comment = Comment.new(text, user_key, picture_key)

      assert Comment.comment(comment, :text) === text
      assert Comment.comment(comment, :user_key) === user_key
      assert Comment.comment(comment, :picture_key) === picture_key
      assert Comment.comment(comment, :depth) === 0
      assert Comment.comment(comment, :parent_key) === nil
    end
  end
end
