CREATE FUNCTION _timecheck(label text, tolerated interval) RETURNS text
AS $$
DECLARE
  ret TEXT;
  lap INTERVAL;
BEGIN
	-- We use now() here to get the time at the
	-- start of the transaction, which started when
	-- this function was called, so the earliest
	-- posssible time
  lap := now()-t FROM _time;

  IF lap <= tolerated THEN
		ret := format(
			'%s interrupted on time',
			label
		);
  ELSE
		ret := format(
			'%s interrupted late: %s (%s tolerated)',
			label, lap, tolerated
		);
  END IF;

  UPDATE _time SET t = clock_timestamp();

  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

CREATE TEMP TABLE _inputs AS
SELECT 1::int as id, ST_Collect(g) g FROM (
 SELECT ST_MakeLine(
   ST_Point(cos(radians(x)),sin(radians(270-x))),
   ST_Point(sin(radians(x)),cos(radians(60-x)))
   ) g
 FROM generate_series(1,720) x
 ) foo
;

-- Run ST_Buffer once to ensure the libary is loaded
-- before taking the start time
SELECT NULL FROM ST_Buffer('POINT(0 0)'::geometry, 3, 1);

CREATE TEMPORARY TABLE _time AS SELECT now() t;

-----------------
-- ST_Buffer
-----------------

SET statement_timeout TO 100;

select ST_Buffer(g,100) from _inputs WHERE id = 1;
--( select (st_dumppoints(st_buffer(st_makepoint(0,0),10000,100000))).geom g) foo;
-- it may take some more to interrupt st_buffer, see
SELECT _timecheck('buffer', '250ms');

-- Not affected by old timeout
SELECT '1', ST_NPoints(ST_Buffer('POINT(4 0)'::geometry, 2, 1));

DROP FUNCTION _timecheck(text, interval);
