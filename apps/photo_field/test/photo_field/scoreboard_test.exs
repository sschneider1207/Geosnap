defmodule PhotoField.ScoreboardTest do
  use ExUnit.Case
  alias PhotoField.Scoreboard

  test "can retrieve score of picture by id" do
    {_user, _category, picture} = TestHelper.new_picture()
    score = Scoreboard.get_score(picture.id)

    assert score == 0
  end

  test "voting on a picture increases score" do
    {user, _category, picture} = TestHelper.new_picture()
    Scoreboard.force_update(picture.id)
    initial_score = Scoreboard.get_score(picture.id)
    {:ok, vote} = Scoreboard.vote_on(picture.id, user.id, 1)
    new_score = Scoreboard.get_score(picture.id)

    assert vote.user_id == user.id
    assert vote.picture_id == picture.id
    assert new_score > initial_score
  end

  test "can't vote on a picture twice with the same user" do
    {user, _category, picture} = TestHelper.new_picture()
    Scoreboard.force_update(picture.id)
    {:ok, _vote} = Scoreboard.vote_on(picture.id, user.id, 1)
    {:error, errors} = Scoreboard.vote_on(picture.id, user.id, -1)

    assert is_map(errors) == true
  end

  test "can't vote on a picture with fake user id" do
    {_user, _category, picture} = TestHelper.new_picture()
    {:error, errors} = Scoreboard.vote_on(picture.id, -1, 1)

    assert is_map(errors) == true
  end

  test "can update a vote for a user" do
    {user, _category, picture} = TestHelper.new_picture()
    Scoreboard.force_update(picture.id)
    {:ok, vote} = Scoreboard.vote_on(picture.id, user.id, 1)
    score = Scoreboard.get_score(picture.id)
    {:ok, new_vote} = Scoreboard.update_vote_on(vote, -1)
    new_score = Scoreboard.get_score(picture.id)

    assert score - vote.value + new_vote.value == new_score
  end

  test "deleted vote is subtracted from score" do
    {user, _category, picture} = TestHelper.new_picture()
    Scoreboard.force_update(picture.id)
    {:ok, vote} = Scoreboard.vote_on(picture.id, user.id, 1)
    score = Scoreboard.get_score(picture.id)
    :ok = Scoreboard.delete_vote(vote)
    new_score = Scoreboard.get_score(picture.id)

    assert score - vote.value == new_score
  end
end
