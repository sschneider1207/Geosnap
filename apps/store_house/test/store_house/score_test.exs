defmodule StoreHouse.ScoreTest do
  use ExUnit.Case
  alias StoreHouse.Score
  require Score

  describe "new/1" do
    test "starting score is zero" do
      score = Score.new("abc")

      assert Score.score(score, :value) === 0
    end
  end
end
