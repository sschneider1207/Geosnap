defmodule Geosnap.Db.Repo.Migrations.AddPicturesTable do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :title, :string, null: false
      add :expiration, :datetime, null: false
      add :picture_path, :string, null: false
      add :thumbnail_path, :string, null: false
      add :md5, :string, null: false
      add :user_id, references(:users, [on_delete: :nilify_all, on_update: :update_all])
      add :category_id, references(:categories, [on_update: :update_all]), null: false
      add :application_id, references(:applications, [on_delete: :nilify_all, on_update: :update_all])

      timestamps
    end

    execute("ALTER TABLE pictures ADD COLUMN location geography(Point,4326)")
    create unique_index(:pictures, [:md5])
    create index(:pictures, [:location], using: "GIST")
  end
end
