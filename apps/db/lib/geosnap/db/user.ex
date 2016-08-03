defmodule Geosnap.Db.User do
  use Ecto.Schema
  alias Geosnap.Db.{Picture, PictureVote, Comment, CommentVote, Changeset}
  use Changeset

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

  def new_changeset(username, password, email) do
    params = %{
      username: username,
      email: email,
      password: password
    }
    changeset(%__MODULE__{}, params)
    |> validate_required(:password)
    |> validate_length(:password, min: 10)
    |> hash_password_field()
  end

  defp changeset(user, params) do
    user
    |> cast(params, [:username, :email, :password, :permissions])
    |> validate_required([:username, :email])
    |> validate_email(:email)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end 
end
