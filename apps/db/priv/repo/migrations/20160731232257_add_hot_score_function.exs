defmodule Geosnap.Db.Repo.Migrations.AddHotScoreFunction do
  use Ecto.Migration

  def up do
    execute ~S"""
    CREATE OR REPLACE FUNCTION hot_score(
        integer,
        timestamp without time zone)
      RETURNS numeric AS
    $BODY$
    DECLARE
          scale integer := 45000;
          precision integer := 7;
          base_time double precision := 1451606400; -- 1/1/2016 00:00:00
          epoch double precision := extract(EPOCH FROM $2);
          value integer := top_score($1);
          ord numeric;
          sign integer;
          seconds double precision;
          result numeric;
   BEGIN
          ord := log(greatest(abs(value), 1));
          IF value > 0 THEN
            sign := 1;
          ELSIF value < 0 THEN
            sign := -1;
          ELSE
            sign := 0;
          END IF;
          seconds := epoch - base_time;
          result := sign * ord + seconds / scale;
          RETURN round(result, precision);
    END;
    $BODY$
      LANGUAGE plpgsql STABLE
      COST 100;
    """
    execute ~S"""
    ALTER FUNCTION hot_score(integer, timestamp without time zone)
      OWNER TO postgres;
    """
  end

  def down do
    execute "DROP FUNCTION hot_score(integer, timestamp without time zone);"
  end
end
