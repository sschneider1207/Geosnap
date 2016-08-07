defmodule Geosnap.Db.Repo.Migrations.AddCommentsTable do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string, null: false
      add :depth, :integer, [null: false, default: 0]
      add :user_id, references(:users, [on_delete: :nilify_all, on_update: :update_all])
      add :picture_id, references(:pictures, [on_delete: :delete_all, on_update: :update_all]), null: false
      add :parent_comment_id, references(:comments, [on_delete: :delete_all, on_update: :update_all])

      timestamps
    end
  end
end
