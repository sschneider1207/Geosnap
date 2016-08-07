defmodule Geosnap.Db.Repo.Migrations.AddPictureVotesTable do
  use Ecto.Migration

  def change do
    create table(:picture_votes) do
      add :value, :integer, null: false
      add :user_id, references(:users, [on_delete: :delete_all, on_update: :update_all])), null: false
      add :picture_id, references(:pictures, [on_delete: :delete_all, on_update: :update_all])), null: false

      timestamps
    end

    create unique_index(:picture_votes, [:user_id, :picture_id])
  end
end
