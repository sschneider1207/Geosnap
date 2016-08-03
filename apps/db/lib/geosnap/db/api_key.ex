defmodule Geosnap.Db.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset
  alias Geosnap.Encryption

  schema "api_keys" do
    field :public_key, :string
    field :private_key, :string, virtual: true
    
    belongs_to :application, Geosnap.Db.Application

    timestamps
  end

  def new_changeset(application_id) do
    {pub, priv} = Encryption.generate_key()
    params = %{
      application_id: application_id,
      public_key: pub,
      private_key: priv
    }
    changeset(%__MODULE__{}, params)
  end

  def rotate_key_changeset(api_key) do
    {pub, priv} = Encryption.generate_key()
    params = %{
      public_key: pub,
      private_key: priv
    }
    changeset(api_key, params)
  end

  defp changeset(api_key, params) do
    api_key
    |> cast(params, [:application_id, :public_key, :private_key])
    |> validate_required([:application_id, :public_key, :private_key])
    |> unique_constraint(:public_key)
    |> unique_constraint(:application_id)
    |> assoc_constraint(:application)
  end
end
