defmodule Geosnap.Db.ApiKey do
  @moduledoc """
  Ecto schema for a Geosnap api key.
  """
  use Geosnap.Db.Schema
  alias Geosnap.Encryption
  alias Ecto.Changeset
  import Changeset

  @type t :: %__MODULE__{}

  schema "api_keys" do
    field :public_key, :string
    field :private_key, :string, virtual: true

    belongs_to :application, Geosnap.Db.Application

    timestamps
  end

  @doc """
  Creates a changeset for a new api key based on an application id.
  """
  @spec new_changeset(integer) :: Changeset.t
  def new_changeset(application_id) do
    {pub, priv} = Encryption.generate_key()
    params = %{
      application_id: application_id,
      public_key: pub,
      private_key: priv
    }
    changeset(%__MODULE__{}, params)
  end

  @doc """
  Rotates the public/private key for an api key.
  """
  @spec rotate_key_changeset(t) :: Changeset.t
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
