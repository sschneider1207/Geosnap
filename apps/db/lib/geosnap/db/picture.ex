defmodule Geosnap.Db.Picture do
  use Ecto.Schema
  alias Geosnap.Db.{User, Category, Comment, PictureVote}

  schema "pictures" do
    field :title, :string
    field :location, Geo.Point
    field :expiration, Ecto.DateTime
    field :picture_path, :string
    field :thumbnail_path, :string
    field :md5, :string

    belongs_to :user, User
    belongs_to :category, Category
    has_many :comments, Comment
    has_many :picture_votes, PictureVote

    timestamps
  end
end
