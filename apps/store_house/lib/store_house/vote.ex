defmodule StoreHouse.Vote do
  use StoreHouse.Table, :vote
  alias StoreHouse.Utils

  @type upvote :: 1

  @type novote :: 0

  @type downvote :: -1

  @doc """
  Creates a new vote row.
  """
  @spec new(String.t, String.t, upvote | downvote) :: tuple
  def new(user_key, picture_key, value) when value in [-1, 1] do
    vote([
      key: {user_key, picture_key},
      value: value,
      inserted_at: Utils.timestamp(),
      updated_at: Utils.timestamp()
    ])
  end

  @doc """
  Changes the value for a vote.
  """
  @spec change_value(tuple, upvote | novote | downvote)
    :: {:ok, tuple} |
       {:error, term}
  def change_value(vote, value) when value in -1..1 do
    case vote(vote, :value) === value do
      true -> {:error, :value_unchanged}
      false -> {:ok, vote(vote, [
          value: value,
          updated_at: Utils.timestamp()
        ])}
    end
  end
  def change_value(_, _) do
    {:error, :invalid_value}
  end
end
