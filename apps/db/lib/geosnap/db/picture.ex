defmodule Geosnap.Db.Picture do
  use Geosnap.Db.Schema
  alias Geosnap.Db.{Application, User, Category, Comment, PictureVote}
  use Geosnap.Db.Changeset
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "pictures" do
    field :title, :string
    field :location, Geo.Point
    field :expiration, Timex.Ecto.DateTime
    field :picture_path, :string
    field :thumbnail_path, :string
    field :md5, :string

    belongs_to :user, User
    belongs_to :category, Category
    belongs_to :application, Application
    has_many :comments, Comment
    has_many :picture_votes, PictureVote

    timestamps
  end

  @doc """
  Creates a changeset for a new picture with the given params.
  """
  @spec new_changeset(map) :: Changeset.t
  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, ~w(title location expiration picture_path
     thumbnail_path md5 user_id category_id application_id)a)
    |> validate_required(~w(title location expiration picture_path
     thumbnail_path md5 user_id category_id)a)
    |> validate_lnglat(:location)
    |> validate_expiration()
    |> unique_constraint(:md5)
    |> assoc_constraint(:user)
    |> assoc_constraint(:category)
    |> assoc_constraint(:application)
  end
end
