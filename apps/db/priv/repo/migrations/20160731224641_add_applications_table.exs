defmodule Geosnap.Db.Repo.Migrations.AddApplicationsTable do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :verified_email, :boolean, [null: false, default: false]

      timestamps
    end
  end
end
