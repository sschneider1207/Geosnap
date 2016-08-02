defmodule Geosnap.Db.Application do
  use Ecto.Schema
  use Geosnap.Db.Changeset

  schema "applications" do
    field :name, :string
    field :email, :string

    has_one :api_key, Geosnap.Db.ApiKey

    timestamps
  end

  def new_changeset(name, email) do
    params = %{
      name: name,
      email: email
    }
    %__MODULE__{}
    |> cast(params, [:name, :email])
    |> validate_email(:email)
  end
end
