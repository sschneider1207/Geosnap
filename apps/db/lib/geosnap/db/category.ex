defmodule Geosnap.Db.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string

    has_many :pictures, Geosnap.Db.Picture

    timestamps
  end

  def new_changeset(name) do
    %__MODULE__{}
    |> cast(%{name: name}, [:name])
    |> validate_required(:name)
  end
end
