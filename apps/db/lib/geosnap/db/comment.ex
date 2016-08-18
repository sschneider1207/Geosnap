defmodule Geosnap.Db.Comment do
  @moduledoc """
  Ecto schema for a comment on a picture.
  """
  use Geosnap.Db.Schema
  use Geosnap.Db.Changeset
  alias Geosnap.Db.{User, Picture}
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "comments" do
    field :text, :string
    field :depth, :integer, default: 0

    belongs_to :user, User
    belongs_to :picture, Picture
    belongs_to :parent_comment, __MODULE__

    timestamps
  end

  @doc """
  Creates a changeset for a new comment.
  """
  @spec new_changeset(map) :: Changeset.t
  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:user_id, :picture_id, :text, :depth, :parent_comment_id])
    |> validate_required([:user_id, :picture_id, :text])
    |> validate_number(:depth, greater_than_or_equal_to: 0)
    |> assoc_constraint(:user)
    |> assoc_constraint(:picture)
    |> assoc_constraint(:parent_comment)
  end

  @doc """
  Creates a changeset that marks the text of a comment as deleted.
  """
  @spec delete_changeset(t) :: Changeset.t
  def delete_changeset(comment) do
    comment
    |> cast(%{text: "<deleted>"}, [:text])
  end
end
