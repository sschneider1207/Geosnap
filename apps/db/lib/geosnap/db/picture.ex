defmodule Geosnap.Db.Picture do
  use Geosnap.Db.Schema
  alias Geosnap.Db.{User, Category, Comment, PictureVote}
  use Geosnap.Db.Changeset
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

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

  def new_changeset(params) do
    %__MODULE__{}
  end
end
