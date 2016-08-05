defmodule Geosnap.Db.Application do
  use Ecto.Schema
  use Geosnap.Db.Changeset
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "applications" do
    field :name, :string
    field :email, :string
    field :verified_email, :boolean, default: false

    has_one :api_key, Geosnap.Db.ApiKey

    timestamps
  end

  @doc """
  Creates a changeset for a new application based on a set of params.
  """
  @spec new_changeset(map) :: Changeset.t
  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:name, :email])
    |> validate_email(:email)
  end

  @doc """
  Creates a changeset for verifying an application's email.
  """
  @spec verify_email(t) :: Changeset.t
  def verify_email(application) do
    application
    |> cast(%{verified_email: true}, [:verified_email])
  end

  @doc """
  Creates a changeset for changing an application's email.
  """
  @spec change_email_changeset(t, map) :: Changeset.t
  def change_email_changeset(application, confirmed_email) do
    params = Map.put(confirmed_email, :verified_email, :false)
    application
    |> cast(params, [:email, :verified_email])
    |> validate_required([:email])
    |> validate_confirmation(:email, required: true)
    |> validate_email(:email)
  end
end
