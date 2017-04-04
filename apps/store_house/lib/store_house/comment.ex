defmodule StoreHouse.Comment do
  use StoreHouse.Table, :comment
  alias StoreHouse.Utils

  @doc """
  Creates a new comment reccord.
  """
  @spec new(String.t, String.t, String.t, non_neg_integer, String.t | nil) :: tuple
  def new(text, user_key, picture_key, depth \\ 0, parent_key \\ nil) do
    comment([
        key: Utils.new_key(),
        text: text,
        user_key: user_key,
        picture_key: picture_key,
        depth: depth,
        parent_key: parent_key,
        inserted_at: Utils.timestamp(),
        updated_at: Utils.timestamp()
      ])
  end
end
