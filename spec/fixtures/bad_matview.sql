-- Timestamp: 2016-10-15 00:00:00 -0300
CREATE MATERIALIZED VIEW bad_matview AS
  SELECT * FROM this_view_doesnt_exist_yet;
