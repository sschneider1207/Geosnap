defmodule Geosnap.Db.Picture do
  use Ecto.Schema

  schema "pictures" do
    field :title, :string
    field :point, Geo.Point
    field :expiration, Ecto.DateTime
    field :picture_path, :string
    field :thumbnail_path, :string

    belongs_to :user, User
    belongs_to :category, Category
    has_many :comments, Comment
    has_many :picture_votes, PictureVote

    timestamps
  end
end
