defmodule Geosnap.Db.Category do
  @moduledoc """
  Ecto schema for a picture category.
  """
  use Geosnap.Db.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string

    has_many :pictures, Geosnap.Db.Picture

    timestamps
  end

  @doc """
  Creates a changeset for a new category based on a name.
  """
  @spec new_changeset(String.t) :: Ecto.Changeset.t
  def new_changeset(name) do
    %__MODULE__{}
    |> cast(%{name: name}, [:name])
    |> validate_required(:name)
    |> unique_constraint(:name)
  end
end
