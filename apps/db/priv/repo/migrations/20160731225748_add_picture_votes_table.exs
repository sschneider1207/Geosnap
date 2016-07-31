defmodule Geosnap.Db.Repo.Migrations.AddPictureVotesTable do
  use Ecto.Migration

  def change do
    create table(:picture_votes) do
      add :value, :integer, null: false
      add :user_id, references(:users), null: false
      add :picture_id, references(:pictures), null: false
      
      timestamps
    end

    create unique_index(:picture_votes, [:user_id, :picture_id])
  end
end
