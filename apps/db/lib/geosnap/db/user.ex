defmodule Geosnap.Db.User do
  use Ecto.Schema
  alias Geosnap.Db.{Picture, PictureVote, Comment, CommentVote}

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :permissions, :integer, default: 0
    
    has_many :pictures, Picture
    has_many :picture_votes, PictureVote
    has_many :comments, Comment
    has_many :comment_votes, CommentVote

    timestamps
  end
end
