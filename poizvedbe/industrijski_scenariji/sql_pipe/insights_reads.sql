WITH deleted_persos AS (
  FROM uc_production.hevo.mongo_personalisations
  |> WHERE deleted = true AND created >= '2023-03-01'
  |> SELECT _id AS personalisation_id
),

docs AS (
  FROM uc_production.hevo.mongo_flipbooks
  |> WHERE publishedat > '2023-03-01' AND deleted = false
  |> SELECT _id AS story_id
),

reads_window AS (
  FROM uc_production.analytics.gold e
  |> INNER JOIN docs d ON e.story_id = d.story_id
  |> LEFT JOIN deleted_persos dp ON e.story_personalisation_id = dp.personalisation_id
  |> LEFT JOIN uc_production.dbt.int_banned_ips b
       ON e.agent_ip = b.ip AND (b.company_id = e.story_company_id OR b.scope = 'Global')
  |> WHERE dp.personalisation_id IS NULL
       AND b.ip IS NULL
       AND e.min_timestamp >= :timestampStart
       AND e.min_timestamp < :timestampEnd
  |> AGGREGATE
       first(e.tenant) AS tenant,
       first(e.story_company_id) AS story_company_id,
       coalesce(first(e.story_publishedVersion), '') AS story_publishedVersion,
       count(distinct e.read_id) FILTER (WHERE e.is_read = true) AS reads
     GROUP BY e.story_id, window(e.min_timestamp, '15 MINUTES')
  |> EXTEND window.start AS windowStart, window.end AS windowEnd
  |> WHERE reads > 0
  |> DROP window
),

reads_total AS (
  FROM reads_window
  |> SELECT story_id, windowEnd
  |> AS w
  |> LEFT JOIN uc_production.analytics.gold e ON e.story_id = w.story_id
  |> LEFT JOIN deleted_persos dp ON e.story_personalisation_id = dp.personalisation_id
  |> LEFT JOIN uc_production.dbt.int_banned_ips b
       ON e.agent_ip = b.ip AND (b.company_id = e.story_company_id OR b.scope = 'Global')
  |> WHERE dp.personalisation_id IS NULL
       AND b.ip IS NULL
       AND e.min_timestamp < w.windowEnd
       AND e.is_read IS TRUE
  |> AGGREGATE count(distinct e.read_id) AS reads
     GROUP BY w.story_id, w.windowEnd
)

FROM reads_window rw
|> LEFT JOIN reads_total rt ON rt.story_id = rw.story_id AND rt.windowEnd = rw.windowEnd
|> LEFT JOIN uc_production.hevo.mongo_tenants t ON rw.tenant = t.name
|> AGGREGATE
     first(t._id) AS tenantId,
     first(rt.reads) AS reads,
     first(rw.reads) AS readsChange
   GROUP BY
     rw.tenant,
     rw.story_id,
     rw.story_company_id,
     rw.story_publishedVersion,
     rw.windowStart,
     rw.windowEnd
|> SELECT
     sha2(
        concat(
          string(tenant),
          string(story_id),
          string(story_publishedVersion),
          string(windowStart),
          string(windowEnd)
        ),
        256
     ) AS id,
     tenant AS tenantName,
     tenantId,
     story_id AS docId,
     story_company_id AS docTeamId,
     story_publishedVersion AS publishedVersionId,
     reads,
     readsChange,
     windowStart,
     windowEnd,
     current_timestamp() AS timestamp
|> ORDER BY reads DESC
|> LIMIT 50
