SELECT 0, ST_AsText(ST_RemoveRepeatedPoints('GEOMETRYCOLLECTION EMPTY'));
SELECT 1, ST_AsText(ST_RemoveRepeatedPoints('LINESTRING(0 0, 1 1, 1 1, 2 2)'));
SELECT 2, ST_AsText(ST_RemoveRepeatedPoints('LINESTRING(0 0, 1 1, 1 1, 2 2, 2 2, 2 2, 2 2, 3 3, 3 3)'));
SELECT 3, ST_AsText(ST_RemoveRepeatedPoints('MULTILINESTRING((0 0, 1 1, 1 1, 2 2, 2 2, 2 2, 2 2, 3 3, 3 3),(5 5, 5 5, 5 5, 4 4, 2 2))'));
SELECT 4, ST_AsText(ST_RemoveRepeatedPoints('POLYGON((0 0, 10 0, 10 10, 10 10, 0 10, 0 10, 0 10, 0 0, 0 0, 0 0),(5 5, 5 5, 5 8, 8 8, 8 8, 8 8, 8 5,8 5, 5 5, 5 5, 5 5, 5 5, 5 5))'));
SELECT 5, ST_AsText(ST_RemoveRepeatedPoints('MULTIPOLYGON(((0 0, 10 0, 10 10, 10 10, 0 10, 0 10, 0 10, 0 0, 0 0, 0 0),(5 5, 5 5, 5 8, 8 8, 8 8, 8 8, 8 5,8 5, 5 5, 5 5, 5 5, 5 5, 5 5)),((50 50, 50 50, 50 50, 50 60, 50 60, 50 60, 60 60, 60 50, 60 50, 50 50),(55 55, 55 58, 58 58, 58 55, 58 55, 55 55)))'));
SELECT 6, ST_AsText(ST_Normalize(ST_RemoveRepeatedPoints('MULTIPOINT(0 0, 10 0, 10 10, 10 10, 0 10, 0 10, 0 10, 0 0, 0 0, 0 0,5 5, 5 5, 5 8, 8 8, 8 8, 8 8, 8 5,8 5, 5 5, 5 5, 5 5, 5 5, 5 5,50 50, 50 50, 50 50, 50 60, 50 60, 50 60, 60 60, 60 50, 60 50, 50 50,55 55, 55 58, 58 58, 58 55, 58 55, 55 55)')));
SELECT 7, ST_AsText(ST_Normalize(ST_RemoveRepeatedPoints('GEOMETRYCOLLECTION(MULTIPOINT(0 0, 10 0, 10 10, 10 10, 0 10, 0 10, 0 10, 0 0, 0 0, 0 0,5 5, 5 5, 5 8, 8 8, 8 8, 8 8, 8 5,8 5, 5 5, 5 5, 5 5, 5 5, 5 5,50 50, 50 50, 50 50, 50 60, 50 60, 50 60, 60 60, 60 50, 60 50, 50 50,55 55, 55 58, 58 58, 58 55, 58 55, 55 55),MULTIPOLYGON(((0 0, 10 0, 10 10, 10 10, 0 10, 0 10, 0 10, 0 0, 0 0, 0 0),(5 5, 5 5, 5 8, 8 8, 8 8, 8 8, 8 5,8 5, 5 5, 5 5, 5 5, 5 5, 5 5)),((50 50, 50 50, 50 50, 50 60, 50 60, 50 60, 60 60, 60 50, 60 50, 50 50),(55 55, 55 58, 58 58, 58 55, 58 55, 55 55))))')));
SELECT 8, ST_AsText(ST_RemoveRepeatedPoints('POINT(0 0)'));
SELECT 9, ST_AsText(ST_RemoveRepeatedPoints('CURVEPOLYGON(CIRCULARSTRING(
                -2 0 0 0,
                -1 -1 1 2,
                0 0 2 4,
                1 -1 3 6,
                2 0 4 8,
                0 2 2 4,
                -2 0 0 0),
                (-1 0 1 2,                                                                      0 0.5 2 4,
                1 0 3 6,                                                                        0 1 3 4,                                                                        -1 0 1 2))'));
SELECT 10, ST_AsText(ST_RemoveRepeatedPoints('LINESTRING(0 0, 0 0)'));
SELECT 11, ST_AsText(ST_RemoveRepeatedPoints('LINESTRING(0 0, 0 0, 0 0, 0 0, 0 0)'));
SELECT 12, ST_SRID(ST_RemoveRepeatedPoints('SRID=3;LINESTRING(0 0, 0 0, 0 0, 0 0, 0 0)'));
SELECT 13, ST_AsText(ST_RemoveRepeatedPoints('LINESTRING(0 0, 1 0, 2 0, 3 0, 4 0)',1.5));
SELECT 14, ST_AsText(ST_RemoveRepeatedPoints('LINESTRING(10 0,10 9,10 10)', 2));

-- #3670
SELECT 15, ST_AsText(ST_RemoveRepeatedPoints('MULTIPOINT(0 0, 0 0, 1 1, 2 2)'::geometry));
SELECT 16, ST_AsText(ST_RemoveRepeatedPoints('MULTIPOINT(0 0, 0 0, 1 1, 2 2)'::geometry,0.1));
SELECT 17, ST_AsText(ST_RemoveRepeatedPoints('MULTIPOINT(0 0, 0 0, 1 1, 4 4)'::geometry,2));
SELECT 18, ST_AsText(ST_RemoveRepeatedPoints('POLYGON((-215922 5325694,-218080 5321866,-218693 5322119,-216112 5325812,-215922 5325694))'::geometry, 10000));

-- Updates the output bbox
WITH geom AS
(
    SELECT ST_RemoveRepeatedPoints('POLYGON((0 0, 10 0, 10 10, 10.5 10.5, 10 10, 0 10, 0 0))', 1) as g
)
Select 19, ST_AsText(g) as geometry, postgis_getbbox(g) AS box from geom;
