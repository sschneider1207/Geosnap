defmodule Geosnap.Db.Repo.Migrations.AddCommentVotesTable do
  use Ecto.Migration

  def change do
    create table(:comment_votes) do
      add :value, :integer, null: false
      add :user_id, references(:users), null: false
      add :comment_id, references(:comments), null: false

      timestamps
    end

    create unique_index(:comment_votes, [:user_id, :comment_id])
  end
end
