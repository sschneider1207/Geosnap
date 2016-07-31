defmodule Geosnap.Db.Repo.Migrations.AddApiKeysTable do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :key, :string, null: :false
      add :application_id, references(:applications), null: false

      timestamps
    end

    create unique_index(:api_keys, [:key])
  end
end
