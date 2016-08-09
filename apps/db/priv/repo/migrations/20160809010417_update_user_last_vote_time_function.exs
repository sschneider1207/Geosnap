defmodule Geosnap.Db.Repo.Migrations.UpdateUserLastVoteTimeFunction do
  use Ecto.Migration

  def up do
    execute ~S"""
    CREATE OR REPLACE FUNCTION update_user_last_vote_time()
      RETURNS trigger AS
    $LAST_VOTE_TIME$
    BEGIN
        UPDATE users SET last_vote_time = now() at time zone 'utc'
          WHERE id = NEW.user_id;
        RETURN NEW;
    END;
    $LAST_VOTE_TIME$
      LANGUAGE plpgsql VOLATILE
      COST 100;
    """

    execute ~S"""
    ALTER FUNCTION update_user_last_vote_time()
      OWNER TO postgres;
    """
  end

  def down do
    execute "DROP FUNCTION update_user_last_vote_time();"
  end
end
