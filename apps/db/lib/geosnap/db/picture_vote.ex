defmodule Geosnap.Db.PictureVote do
  use Geosnap.Db.Schema
  use Geosnap.Db.Changeset
  alias Geosnap.Db.{User, Picture}
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "picture_votes" do
    field :value, :integer
    
    belongs_to :user, User
    belongs_to :picture, Picture

    timestamps
  end

  @doc """
  Creates a new changeset for a user's vote for a given picture.
  """
  @spec new_changeset(map) :: Changeset.t
  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:user_id, :picture_id, :value])
    |> validate_required([:user_id, :picture_id, :value])
    |> validate_number(:value, [greater_than_or_equal_to: -1, less_than_or_equal_to: 1])
    |> assoc_constraint(:user)
    |> assoc_constraint(:picture)
    |> unique_constraint(:picture, name: :picture_votes_user_id_picture_id_index)
  end

  @doc """
  Creates a changeset for updating the value of an existing vote.
  """
  @spec update_vote_changeset(t, integer) :: Changeset.t
  def update_vote_changeset(vote, new_value) do
    vote
    |> cast(%{value: new_value}, [:value])
    |> validate_required([:value])
    |> validate_number(:value, [greater_than_or_equal_to: -1, less_than_or_equal_to: 1])
  end
end
