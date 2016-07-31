defmodule Geosnap.Db.Repo.Migrations.AddPicturesTable do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :title, :string, null: false
      add :point, :geography, null: false
      add :expiration, :datetime, null: false
      add :picture_path, :string, null: false
      add :thumbnail_path, :string, null: false
      add :user_id, references(:users), null: false
      add :category_id, references(:categories), null: false

      timestamps
    end
  end
end
