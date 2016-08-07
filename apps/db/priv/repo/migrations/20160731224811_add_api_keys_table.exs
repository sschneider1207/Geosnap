defmodule Geosnap.Db.Repo.Migrations.AddApiKeysTable do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :public_key, :string, null: :false
      add :application_id, references(:applications, [on_delete: :delete_all, on_update: :update_all]), null: false

      timestamps
    end

    create unique_index(:api_keys, [:public_key])
    create unique_index(:api_keys, [:application_id])
  end
end
