defmodule Geosnap.Db.Repo.Migrations.AddPicturesTable do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :title, :string, null: false
      add :expiration, :datetime, null: false
      add :picture_path, :string, null: false
      add :thumbnail_path, :string, null: false
      add :md5, :string, null: false
      add :user_id, references(:users), null: false
      add :category_id, references(:categories), null: false

      timestamps
    end

    execute("ALTER TABLE pictures ADD COLUMN location geography(Point,4326)")
    create unique_index(:pictures, [:md5])
    execute("CREATE INDEX pictures_location_index ON pictures USING GIST ( location )")
  end
end
