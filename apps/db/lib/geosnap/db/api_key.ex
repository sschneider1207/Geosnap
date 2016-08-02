defmodule Geosnap.Db.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_keys" do
    field :key, :string
    
    belongs_to :application, Geosnap.Db.Application

    timestamps
  end

  def new_changeset(params \\ %{}) do
  end
end
