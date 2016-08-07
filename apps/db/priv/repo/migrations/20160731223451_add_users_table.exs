defmodule Geosnap.Db.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :verified_email, :boolean, [null: false, default: false]
      add :permissions, :integer, [null: false, default: 0]
      add :last_vote_time, :datetime

      timestamps
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
