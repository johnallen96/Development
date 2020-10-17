WITH search AS (
  SELECT * FROM (
    SELECT
      TD_DATE_TRUNC('day', time) date,
      SUBSTR(root_search_id, 1, 8) search_id,
      -- MD5 hashing is readily available in the warehouse environment and is fine to use for this purpose since user ids are
      -- hashes to begin with.
      SUBSTR(TD_MD5(user_id), 1, 8) user_id,
      -- SNME is the experiment id, it's short for 'Search no manual elevations'
      CAST(JSON_EXTRACT(experiments_json, '$.SNME') AS VARCHAR) experiment_group,
      user_tier,
      query,
      media_types,
      num_elevations,
      -- multiple clicks on the same image within the same result set are considered to be a single click for this analysis
      distinct_usage_count num_clicks,
      num_exported_results,
      num_licenses
    FROM fact_search_image
    WHERE TD_TIME_RANGE(time, '2018-04-01')
    -- restrict to English users for simpler analysis
    AND query_locale LIKE 'en%'
    -- remove queries which were not typed by a user
    AND is_organic = 1
    -- ignore mobile clients as they're still not reporting clicks properly
    AND platform = 'WEB'
    -- queries must include an image result filter (raster and/or vector)
    AND media_types IN ('R', 'V', 'RV')
    -- exclude marketplace and editor 2, there are still some remaining data quality issues
    AND client_feature IS NULL
  ) A
  WHERE experiment_group IS NOT NULL
),
min_search_date AS (
  SELECT MIN(date) min_date FROM search
),
queries_with_elevations AS (
  SELECT DISTINCT
    query,
    media_types,
    user_tier
  FROM search
  WHERE num_elevations > 0
  AND experiment_group = 'A'
)
SELECT
  ((s.date - msd.min_date) / (60 * 60 * 24)) + 1 experiment_day,
  s.search_id,
  s.user_id,
  s.experiment_group,
  s.user_tier,
  s.query,
  s.media_types,
  s.num_elevations,
  s.num_clicks,
  s.num_exported_results,
  s.num_licenses
FROM search s
JOIN queries_with_elevations qe
  ON s.query = qe.query
  AND s.media_types = qe.media_types
  AND s.user_tier = qe.user_tier
CROSS JOIN min_search_date msd
