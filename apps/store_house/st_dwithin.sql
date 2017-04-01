-- st_dwithin(a, b, n)
SELECT $1 && _ST_Expand($2,$3) AND $2 && _ST_Expand($1,$3) AND _ST_DWithin($1, $2, $3, true)

--https://github.com/postgis/postgis/blob/bd3177743db5cb786deb05d7327f39a5cec2daf6/liblwgeom/g_serialized.txt

-- _ST_Expand(a, b) => geography_expand
-- https://trac.osgeo.org/postgis/browser/tags/2.3.2/postgis/geography_measurement.c#L465
-- https://github.com/postgis/postgis/blob/svn-trunk/postgis/geography_measurement.c#L465

-- _ST_Dwithin(a, b, n, true) => geography_dwithin
-- https://trac.osgeo.org/postgis/browser/tags/2.3.2/postgis/geography_measurement.c#L276
-- https://github.com/postgis/postgis/blob/svn-trunk/postgis/geography_measurement.c#L276
