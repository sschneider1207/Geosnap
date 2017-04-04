defmodule StoreHouse.Score do
  use StoreHouse.Table, :score

  @doc """
  Creates a new score row.
  """
  @spec new(String.t) :: tuple
  def new(picture_key) do
    score([key: picture_key, value: 0])
  end
end
