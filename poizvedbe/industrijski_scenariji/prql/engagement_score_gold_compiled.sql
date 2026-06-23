WITH table_6 AS (
  SELECT
    `read.id` AS read_id,
    `story.tenant` AS story_tenant,
    `story.id` AS story_id,
    `story.personalisation.id` AS story_personalisation_id,
    `page.id` AS page_id,
    `type` AS _expr_6,
    duration,
    `read.utm.content` AS _expr_9,
    `read.utm.term` AS _expr_10,
    `read.utm.campaign` AS _expr_11,
    `read.utm.medium` AS _expr_12,
    `read.utm.source` AS _expr_13,
    `agent.browser.version` AS _expr_14,
    `agent.browser.name` AS _expr_15,
    `agent.os.version` AS _expr_16,
    `agent.os.name` AS _expr_17,
    `agent.referer.type` AS _expr_18,
    `agent.referer.label` AS _expr_19,
    `agent.location.state` AS _expr_20,
    `agent.device.type` AS _expr_21,
    `agent.source` AS _expr_22,
    `agent.location.country` AS _expr_23,
    `story.author.id` AS _expr_24,
    `reader.id` AS _expr_25,
    `page.immerse_page_group_id` AS _expr_26,
    `page.immerse_page_index` AS _expr_27,
    `tracker.timestamp` AS _expr_28,
    `story.company.id` AS _expr_29
  FROM
    uc_production.analytics.silver AS e
  WHERE
    year = 2026
    AND month = 6
    AND day = 15
    AND tenant = 'team'
),
cfj AS (
  SELECT
    _id AS id,
    title,
    created,
    company,
    __turtl__tenant_name AS tenant_name,
    from_json(topics, 'array<string>') AS doc_topics,
    publishedpages,
    CASE
      WHEN publishedpages = '[]'
      OR publishedpages IS NULL THEN from_json(
        pages,
        'array<struct<_id:string, topics:array<string>>>'
      )
      ELSE from_json(
        publishedpages,
        'array<struct<_id:string, topics:array<string>>>'
      )
    END AS chapter_from_json
  FROM
    uc_production.hevo.mongo_flipbooks
  WHERE
    deleted = false
),
c AS (
  SELECT
    id,
    title,
    created,
    company,
    tenant_name,
    doc_topics,
    explode_outer(chapter_from_json) AS chapter
  FROM
    cfj
),
d AS (
  SELECT
    id,
    title,
    created,
    company,
    tenant_name,
    doc_topics,
    chapter._id AS chapter_id,
    chapter.topics AS chapter_topics
  FROM
    c
),
table_5 AS (
  SELECT
    table_6.read_id,
    table_6.story_tenant,
    table_6.story_id,
    table_6.story_personalisation_id,
    table_6.page_id,
    table_6._expr_6,
    table_6.duration,
    d.chapter_topics,
    d.doc_topics,
    table_6._expr_9,
    table_6._expr_10,
    table_6._expr_11,
    table_6._expr_12,
    table_6._expr_13,
    table_6._expr_14,
    table_6._expr_15,
    table_6._expr_16,
    table_6._expr_17,
    table_6._expr_18,
    table_6._expr_19,
    table_6._expr_20,
    table_6._expr_21,
    table_6._expr_22,
    table_6._expr_23,
    table_6._expr_24,
    table_6._expr_25,
    d.company,
    table_6._expr_26,
    table_6._expr_27,
    table_6._expr_28,
    table_6._expr_29
  FROM
    table_6
    INNER JOIN d ON d.id = table_6.story_id
    AND (
      d.chapter_id = table_6.page_id
      OR d.chapter_id IS NULL
    )
    LEFT OUTER JOIN uc_production.hevo.mongo_personalisations AS p ON p.flipbook = table_6.story_id
    AND p._id = table_6.story_personalisation_id
  WHERE
    table_6.page_id <> 'COOKIE'
    AND (
      p.deleted IS NULL
      OR p.deleted = false
    )
),
table_4 AS (
  SELECT
    table_5.read_id,
    table_5.story_tenant,
    table_5.story_id,
    table_5.story_personalisation_id,
    table_5.page_id,
    date_format(table_5._expr_28, 'yyyy-MM-dd') AS read_date,
    table_5._expr_6,
    table_5.duration,
    CASE
      WHEN table_5._expr_6 = 'immersion_start'
      OR table_5._expr_6 = 'immerse_page_turn' THEN concat(
        table_5.page_id,
        '_',
        coalesce(table_5._expr_26, 'unknown'),
        '_',
        coalesce(table_5._expr_27, 'unknown')
      )
      ELSE NULL
    END AS _expr_7,
    CASE
      WHEN table_5._expr_6 = 'immersion'
      OR table_5._expr_6 = 'surf'
      OR table_5._expr_6 = 'surf_start'
      AND table_5.page_id = 'END' THEN table_5.page_id
      ELSE NULL
    END AS _expr_8,
    table_5.chapter_topics,
    table_5.doc_topics,
    table_5._expr_9,
    table_5._expr_10,
    table_5._expr_11,
    table_5._expr_12,
    table_5._expr_13,
    table_5._expr_14,
    table_5._expr_15,
    table_5._expr_16,
    table_5._expr_17,
    table_5._expr_18,
    table_5._expr_19,
    table_5._expr_20,
    table_5._expr_21,
    table_5._expr_22,
    table_5._expr_23,
    table_5._expr_24,
    table_5._expr_25,
    table_5.company,
    table_5._expr_26,
    table_5._expr_27
  FROM
    table_5
    LEFT OUTER JOIN uc_production.dbt.int_banned_ips AS bi ON bi.company_id = table_5._expr_29
    OR bi.scope = 'Global'
  WHERE
    bi.ip IS NULL
),
ana AS (
  SELECT
    read_id,
    story_tenant,
    story_id,
    story_personalisation_id,
    page_id,
    read_date,
    first(company) AS team_id,
    first(_expr_25) AS reader_id,
    first(_expr_24) AS story_author_id,
    first(_expr_23) AS agent_location_country,
    first(_expr_22) AS agent_source,
    first(_expr_21) AS agent_device_type,
    first(_expr_20) AS agent_location_state,
    first(_expr_19) AS agent_referer_label,
    first(_expr_18) AS agent_referer_type,
    first(_expr_17) AS agent_os_name,
    first(_expr_16) AS agent_os_version,
    first(_expr_15) AS agent_browser_name,
    first(_expr_14) AS agent_browser_version,
    first(_expr_13) AS read_utm_source,
    first(_expr_12) AS read_utm_medium,
    first(_expr_11) AS read_utm_campaign,
    first(_expr_10) AS read_utm_term,
    first(_expr_9) AS read_utm_content,
    first(doc_topics) AS doc_topics,
    first(chapter_topics) AS chapter_topics,
    COUNT(*) AS number_of_events,
    array_agg(DISTINCT _expr_8) AS distinct_surf_pages_read,
    array_agg(DISTINCT _expr_7) AS distinct_immerse_pages_read_v2,
    COALESCE(
      SUM(
        case
          when _expr_6 = 'surf' then 1
        end
      ),
      0
    ) > 0 AS is_read,
    COALESCE(
      SUM(
        case
          when _expr_6 = 'surf' then coalesce(duration, 0)
        end
      ),
      0
    ) AS surf_time_ms,
    COALESCE(
      SUM(
        case
          when e_type in (
            'immersion',
            'immersion_viewed',
            'immerse_page_turn'
          ) then coalesce(e.duration, 0)
        end
      ),
      0
    ) AS immerse_time_ms
  FROM
    table_4
  GROUP BY
    read_id,
    story_tenant,
    story_id,
    story_personalisation_id,
    page_id,
    read_date
  HAVING
    is_read
),
table_1 AS (
  SELECT
    tenant,
    id AS chapter_story_id,
    explode(num_all_pages_per_surf) AS (chapter_id, chapter_pages)
  FROM
    uc_production.default.doc_features
),
table_0 AS (
  SELECT
    tenant,
    chapter_story_id,
    chapter_id,
    chapter_pages
  FROM
    table_1
),
table_3 AS (
  SELECT
    ana.read_date,
    ana.reader_id,
    ana.story_id,
    ana.story_personalisation_id,
    ana.page_id,
    ana.story_tenant,
    ana.team_id,
    ana.story_author_id,
    ana.agent_location_country,
    ana.agent_source,
    ana.agent_device_type,
    ana.agent_location_state,
    ana.agent_referer_label,
    ana.agent_referer_type,
    ana.agent_os_name,
    ana.agent_os_version,
    ana.agent_browser_name,
    ana.agent_browser_version,
    ana.read_utm_source,
    ana.read_utm_medium,
    ana.read_utm_campaign,
    ana.read_utm_term,
    ana.read_utm_content,
    ana.doc_topics,
    ana.chapter_topics,
    table_0.chapter_pages,
    array_distinct(
      flatten(
        flatten(
          array(
            array_agg(ana.distinct_surf_pages_read),
            array_agg(ana.distinct_immerse_pages_read_v2)
          )
        )
      )
    ) AS read_pages_array,
    COALESCE(
      COALESCE(
        SUM(
          COALESCE(
            COALESCE(
              COALESCE(ana.surf_time_ms, 0 + ana.immerse_time_ms),
              0
            ),
            0
          )
        ),
        0
      ) / 1000,
      0
    ) AS time_spent,
    COALESCE(SUM(ana.number_of_events), 0) AS total_number_of_events
  FROM
    ana
    LEFT OUTER JOIN table_0 ON ana.story_id = table_0.chapter_story_id
    AND ana.page_id = table_0.chapter_id
    AND ana.story_tenant = table_0.tenant
  GROUP BY
    ana.read_date,
    ana.reader_id,
    ana.story_id,
    ana.story_personalisation_id,
    ana.page_id,
    ana.story_tenant,
    ana.team_id,
    ana.story_author_id,
    ana.agent_location_country,
    ana.agent_source,
    ana.agent_device_type,
    ana.agent_location_state,
    ana.agent_referer_label,
    ana.agent_referer_type,
    ana.agent_os_name,
    ana.agent_os_version,
    ana.agent_browser_name,
    ana.agent_browser_version,
    ana.read_utm_source,
    ana.read_utm_medium,
    ana.read_utm_campaign,
    ana.read_utm_term,
    ana.read_utm_content,
    ana.doc_topics,
    ana.chapter_topics,
    table_0.chapter_pages
),
met AS (
  SELECT
    read_date,
    reader_id,
    story_id,
    story_personalisation_id,
    page_id,
    story_tenant,
    team_id,
    story_author_id,
    agent_location_country,
    agent_source,
    agent_device_type,
    agent_location_state,
    agent_referer_label,
    agent_referer_type,
    agent_os_name,
    agent_os_version,
    agent_browser_name,
    agent_browser_version,
    read_utm_source,
    read_utm_medium,
    read_utm_campaign,
    read_utm_term,
    read_utm_content,
    doc_topics,
    chapter_topics,
    chapter_pages,
    read_pages_array,
    time_spent,
    total_number_of_events,
    array_size(read_pages_array) AS number_of_read_pages,
    time_spent / array_size(read_pages_array) AS dts,
    log(time_spent / array_size(read_pages_array) + 1) AS log_dts,
    array_size(read_pages_array) / chapter_pages AS dcp_without_normalisation,
    CASE
      WHEN array_size(read_pages_array) / chapter_pages > 1 THEN 1
      ELSE array_size(read_pages_array) / chapter_pages
    END AS dcp_non_adjusted,
    CASE
      WHEN array_size(read_pages_array) / chapter_pages > 1 THEN 1
      ELSE array_size(read_pages_array) / chapter_pages
    END * log10(chapter_pages + 1) AS dcp,
    total_number_of_events / array_size(read_pages_array) AS dee,
    log(
      total_number_of_events / array_size(read_pages_array) + 1
    ) AS log_dee
  FROM
    table_3
),
table_2 AS (
  SELECT
    reader_id,
    story_id,
    story_personalisation_id,
    team_id,
    story_author_id,
    agent_location_country,
    agent_source,
    agent_device_type,
    agent_location_state,
    agent_referer_label,
    agent_referer_type,
    agent_os_name,
    agent_os_version,
    agent_browser_name,
    agent_browser_version,
    read_utm_source,
    read_utm_medium,
    read_utm_campaign,
    read_utm_term,
    read_utm_content,
    doc_topics,
    chapter_topics,
    story_tenant,
    page_id,
    read_date,
    log_dee,
    0.6931471805599453 AS _expr_0,
    10.238959288823757 AS _expr_1,
    dcp,
    0.01782918846332898 AS _expr_2,
    1.9138138523837167 AS _expr_3,
    log_dts,
    0 AS _expr_4,
    13.025439534395558 AS _expr_5
  FROM
    met
)
SELECT
  table_2.read_date AS year_day,
  table_2.reader_id,
  table_2.story_id,
  table_2.story_personalisation_id,
  table_2.page_id AS chapter_id,
  table_2.story_tenant AS tenant,
  table_2.team_id,
  ira.company_key,
  table_2.story_author_id,
  table_2.agent_location_country,
  table_2.agent_source,
  table_2.agent_device_type,
  table_2.agent_location_state,
  table_2.agent_referer_label,
  table_2.agent_referer_type,
  table_2.agent_os_name,
  table_2.agent_os_version,
  table_2.agent_browser_name,
  table_2.agent_browser_version,
  table_2.read_utm_source,
  table_2.read_utm_medium,
  table_2.read_utm_campaign,
  table_2.read_utm_term,
  table_2.read_utm_content,
  table_2.doc_topics,
  table_2.chapter_topics,
  (table_2.log_dts - table_2._expr_4) / (table_2._expr_5 - table_2._expr_4) AS norm_dts,
  (table_2.dcp - table_2._expr_2) / (table_2._expr_3 - table_2._expr_2) AS norm_dcp,
  (table_2.log_dee - table_2._expr_0) / (table_2._expr_1 - table_2._expr_0) AS norm_dee,
  (
    (table_2.log_dts - table_2._expr_4) / (table_2._expr_5 - table_2._expr_4) + (table_2.dcp - table_2._expr_2) / (table_2._expr_3 - table_2._expr_2) + (table_2.log_dee - table_2._expr_0) / (table_2._expr_1 - table_2._expr_0)
  ) * 100 AS engagement_score
FROM
  table_2
  LEFT OUTER JOIN uc_production.aai.int_reader_accounts AS ira ON ira.reader_id = table_2.reader_id
  AND ira.doc_id = table_2.story_id
  AND ira.personalisation_id = table_2.story_personalisation_id
  AND ira.team_id = table_2.team_id
  AND ira.tenant = table_2.story_tenant
ORDER BY
  engagement_score DESC

-- Generated by PRQL compiler version:0.13.12 (https://prql-lang.org)
