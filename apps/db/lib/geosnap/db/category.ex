defmodule Geosnap.Db.Category do
  use Ecto.Schema

  schema "categories" do
    field :name, :string

    has_many :pictures, Geosnap.Db.Picture

    timestamps
  end
end
