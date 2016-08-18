defmodule Geosnap.Db.User do
  @moduledoc """
  Ecto schema for a user.
  """
  use Geosnap.Db.Schema
  use Geosnap.Db.Changeset
  alias Geosnap.Db.{Picture, PictureVote, Comment}
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :verified_email, :boolean, default: false
    field :permissions, :integer, default: 0
    field :last_vote_time, Timex.Ecto.DateTime

    has_many :pictures, Picture
    has_many :picture_votes, PictureVote
    has_many :comments, Comment

    timestamps
  end

  @doc """
  Creates a changeset for a new user based on a set of params.
  """
  @spec new_changeset(map) :: Changeset.t
  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:username, :email, :password, :permissions])
    |> validate_required([:username, :email, :password])
    |> validate_email(:email)
    |> validate_length(:password, min: 10)
    |> hash_password_field()
    |> validate_number(:permissions, greater_than_or_equal_to: 0)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc """
  Creates a changeset that marks a user's email as verified.
  """
  @spec verify_email_changeset(t) :: Changeset.t
  def verify_email_changeset(user) do
    user
    |> cast(%{verified_email: true}, [:verified_email])
  end

  @doc """
  Creates a changeset for changing a user's password.
  A confirmation parameter `:password_confirmation` is expected.
  """
  @spec change_password_changeset(t, map) :: Changeset.t
  def change_password_changeset(user, confirmed_pwd) do
    user
    |> cast(confirmed_pwd, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password, required: true)
    |> hash_password_field()
  end

  @doc """
  Creates a changeset for changing a user's email.
  A confirmation parameter `:email_confirmation` is expected.
  """
  @spec change_email_changeset(t, map) :: Changeset.t
  def change_email_changeset(user, confirmed_email) do
    params = Map.put(confirmed_email, :verified_email, false)
    user
    |> cast(params, [:email, :verified_email])
    |> validate_required([:email])
    |> validate_confirmation(:email, required: true)
    |> validate_email(:email)
  end

  @doc """
  Creates a changeset for updating a user's permissions.
  """
  @spec update_permissions_changeset(t, integer) :: Changeset.t
  def update_permissions_changeset(user, permissions) do
    user
    |> cast(%{permissions: permissions}, [:permissions])
    |> validate_required(:permissions)
    |> validate_number(:permissions, greater_than_or_equal_to: 0)
  end
end
