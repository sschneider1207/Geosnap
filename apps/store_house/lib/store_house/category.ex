defmodule StoreHouse.Category do
  use StoreHouse.Table, :category
  alias StoreHouse.Utils

  @doc """
  Create a new category record.
  """
  @spec new(atom, String.t) :: tuple
  def new(name, color) do
    category([
      key: name,
      color: color,
      inserted_at: Utils.timestamp(),
      updated_at: Utils.timestamp()
    ])
  end

  @doc """
  Change the key on a category record.
  """
  @spec change_key(tuple, atom) :: {:ok, tuple} | {:error, term}
  def change_key(category, new_key) do
    case category(category, :key) do
      ^new_key -> {:error, :key_unchanged}
      _ ->
        row = category(category, [
          key: new_key,
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
    end
  end

  @doc """
  Change the color on a category record.
  """
  @spec change_color(tuple, String.t) :: {:ok, tuple} | {:error, term}
  def change_color(category, new_color) do
    case category(category, :color) do
      ^new_color -> {:error, :color_unchanged}
      _ ->
        row = category(category, [
          color: new_color,
          updated_at: Utils.timestamp()
        ])
        {:ok, row}
    end
  end
end
