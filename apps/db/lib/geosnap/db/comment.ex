defmodule Geosnap.Db.Comment do
  use Ecto.Schema
  alias Geosnap.Db.{User, Picture}

  schema "comments" do
    field :text, :string
    field :depth, :integer, default: 0
    
    belongs_to :user, User
    belongs_to :picture, Picture
    belongs_to :parent_comment, __MODULE__

    timestamps
  end
end
