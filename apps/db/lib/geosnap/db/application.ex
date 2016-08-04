defmodule Geosnap.Db.Application do
  use Ecto.Schema
  use Geosnap.Db.Changeset

  schema "applications" do
    field :name, :string
    field :email, :string

    has_one :api_key, Geosnap.Db.ApiKey

    timestamps
  end

  @doc """
  Creates a changeset for a new application based on a set of params.
  """
  @spec new_changeset(map) :: Ecto.Changeset.t
  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:name, :email])
    |> validate_email(:email)
  end
end
