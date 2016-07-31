defmodule Geosnap.Db.Repo.Migrations.AddTopScoreFunction do
  use Ecto.Migration

  def up do
    execute ~S"""
    CREATE OR REPLACE FUNCTION top_score(integer)
      RETURNS integer AS
    $BODY$
    DECLARE
        value integer;
    BEGIN
        SELECT sum(v.value) INTO value FROM picture_votes AS v
        WHERE v.picture_id = $1;
        IF value IS NULL
        THEN
          RETURN 0;
        ELSE
          RETURN value;
        END IF;
    END;
    $BODY$
      LANGUAGE plpgsql STABLE
      COST 100;
    """

    execute ~S"""
    ALTER FUNCTION top_score(integer)
      OWNER TO pi;
    """
  end

  def down do
    execute "DROP FUNCTION top_score(integer);"
  end
end
