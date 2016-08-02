defmodule Geosnap.Db.Application do
  use Ecto.Schema

  schema "applications" do
    field :name, :string
    field :email, :string

    has_one :api_key, ApiKey

    timestamps
  end
end
