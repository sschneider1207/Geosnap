defmodule Geosnap.Db.CommentVote do
  use Geosnap.Db.Schema
  alias Geosnap.Db.{User, Comment}

  schema "comment_votes" do
    field :value, :integer

    belongs_to :user, User
    belongs_to :comment, Comment

    timestamps
  end
end
