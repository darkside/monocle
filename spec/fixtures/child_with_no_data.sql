-- Timestamp: 2016-10-15 00:00:00 -0300
CREATE MATERIALIZED VIEW child_with_no_data AS
  SELECT * FROM parent_with_no_data
WITH NO DATA;
