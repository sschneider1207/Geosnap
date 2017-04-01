defmodule StoreHouse.VoteTest do
  use ExUnit.Case
  alias StoreHouse.Vote
  require Vote
  @uk "a"
  @pk "b"
  @value 1

  describe "new/3" do
    test "fields are set correctly with valid params" do
      vote = Vote.new(@uk, @pk, @value)

      assert Vote.vote(vote, :key) === {@uk, @pk}
      assert Vote.vote(vote, :value) === @value
    end
  end

  describe "change_value/2" do
    test "update with valid new value" do
      vote = Vote.new(@uk, @pk, @value)
      new_value = -1
      {:ok, vote2} = Vote.change_value(vote, new_value)

      assert Vote.vote(vote2, :value) === new_value
    end

    test "can't change to same value" do
      vote = Vote.new(@uk, @pk, @value)
      assert {:error, :value_unchanged} = Vote.change_value(vote, @value)
    end

    test "can't change to out of range value" do
      vote = Vote.new(@uk, @pk, @value)
      assert {:error, :invalid_value} = Vote.change_value(vote, 2)
    end
  end
end
