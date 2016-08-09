defmodule Geosnap.Db.Repo.Migrations.UpdateUserLastVoteTimeTrigger do
  use Ecto.Migration

  def up do
    execute ~S"""
    CREATE TRIGGER update_user_last_vote_time_pictures AFTER INSERT OR UPDATE ON picture_votes
      FOR EACH ROW EXECUTE PROCEDURE update_user_last_vote_time();
    """

    execute ~S"""
    CREATE TRIGGER update_user_last_vote_time_comments AFTER INSERT OR UPDATE ON comment_votes
      FOR EACH ROW EXECUTE PROCEDURE update_user_last_vote_time();
    """
  end

  def down do
    execute "DROP TRIGGER update_user_last_vote_time_pictures on picture_votes;"

    execute "DROP TRIGGER update_user_last_vote_time_comments on comment_votes;"
  end
end
