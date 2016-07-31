defmodule Geosnap.Db.Repo.Migrations.AddApplicationsTable do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :name, :string, null: :false
      add :email, :string, null: :false

      timestamps
    end
  end
end
