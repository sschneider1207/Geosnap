defmodule Geosnap.Db.Repo.Migrations.AddCommentsTable do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string, null: false
      add :depth, :integer, [null: false, default: 0]
      add :user_id, references(:users), null: false
      add :picture_id, references(:pictures), null: false
      add :parent_comment_id, references(:comments)

      timestamps
    end
  end
end
