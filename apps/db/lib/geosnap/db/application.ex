defmodule Geosnap.Db.Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applications" do
    field :name, :string
    field :email, :string

    has_one :api_key, ApiKey

    timestamps
  end

  def new_changeset(name, email) do
    params = %{
      name: name,
      email: email
    }
    %__MODULE__{}
    |> cast(params, [:name, :email])
  end
end
