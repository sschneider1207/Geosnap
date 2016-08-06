defmodule Geosnap.Db.PictureVote do
  use Geosnap.Db.Schema
  alias Geosnap.Db.{User, Picture}

  schema "picture_votes" do
    field :value, :integer
    
    belongs_to :user, User
    belongs_to :picture, Picture

    timestamps

  end
end
