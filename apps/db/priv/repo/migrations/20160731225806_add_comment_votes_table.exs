defmodule Geosnap.Db.Repo.Migrations.AddCommentVotesTable do
  use Ecto.Migration

  def change do
    create table(:comment_votes) do
      add :value, :integer, null: false
      add :user_id, references(:users, [on_delete: :delete_all, on_update: :update_all])), null: false
      add :comment_id, references(:comments, [on_delete: :delete_all, on_update: :update_all])), null: false

      timestamps
    end

    create unique_index(:comment_votes, [:user_id, :comment_id])
  end
end
