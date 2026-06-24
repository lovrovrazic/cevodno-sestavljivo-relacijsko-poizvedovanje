WITH table_6 AS (
  SELECT
    `read.id`,
    `story.tenant`,
    `story.id`,
    `story.personalisation.id`,
    `page.id`,
    type,
    duration,
    `read.utm.content`,
    `read.utm.term`,
    `read.utm.campaign`,
    `read.utm.medium`,
    `read.utm.source`,
    `agent.browser.version`,
    `agent.browser.name`,
    `agent.os.version`,
    `agent.os.name`,
    `agent.referer.type`,
    `agent.referer.label`,
    `agent.location.state`,
    `agent.device.type`,
    `agent.source`,
    `agent.location.country`,
    `story.author.id`,
    `reader.id`,
    `page.immerse_page_group_id`,
    `page.immerse_page_index`,
    `tracker.timestamp`,
    `agent.ip`,
    `story.company.id`
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
    table_6.`read.id`,
    table_6.`story.tenant`,
    table_6.`story.id`,
    table_6.`story.personalisation.id`,
    table_6.`page.id`,
    table_6.type,
    table_6.duration,
    d.chapter_topics,
    d.doc_topics,
    table_6.`read.utm.content`,
    table_6.`read.utm.term`,
    table_6.`read.utm.campaign`,
    table_6.`read.utm.medium`,
    table_6.`read.utm.source`,
    table_6.`agent.browser.version`,
    table_6.`agent.browser.name`,
    table_6.`agent.os.version`,
    table_6.`agent.os.name`,
    table_6.`agent.referer.type`,
    table_6.`agent.referer.label`,
    table_6.`agent.location.state`,
    table_6.`agent.device.type`,
    table_6.`agent.source`,
    table_6.`agent.location.country`,
    table_6.`story.author.id`,
    table_6.`reader.id`,
    d.company,
    table_6.`page.immerse_page_group_id`,
    table_6.`page.immerse_page_index`,
    table_6.`tracker.timestamp`,
    table_6.`agent.ip`,
    table_6.`story.company.id`
  FROM
    table_6
    INNER JOIN d ON d.id = table_6.`story.id`
    AND (
      d.chapter_id = table_6.`page.id`
      OR d.chapter_id IS NULL
    )
    LEFT OUTER JOIN uc_production.hevo.mongo_personalisations AS p ON p.flipbook = table_6.`story.id`
    AND p._id = table_6.`story.personalisation.id`
  WHERE
    table_6.`page.id` <> 'COOKIE'
    AND (
      p.deleted IS NULL
      OR p.deleted = false
    )
),
table_4 AS (
  SELECT
    table_5.`read.id`,
    table_5.`story.tenant`,
    table_5.`story.id`,
    table_5.`story.personalisation.id`,
    table_5.`page.id`,
    date_format(table_5.`tracker.timestamp`, 'yyyy-MM-dd') AS read_date,
    table_5.type,
    table_5.duration,
    CASE
      WHEN table_5.type = 'immersion_start'
      OR table_5.type = 'immerse_page_turn' THEN concat(
        table_5.`page.id`,
        '_',
        coalesce(table_5.`page.immerse_page_group_id`, 'unknown'),
        '_',
        coalesce(table_5.`page.immerse_page_index`, 'unknown')
      )
      ELSE NULL
    END AS _expr_6,
    CASE
      WHEN table_5.type = 'immersion'
      OR table_5.type = 'surf'
      OR table_5.type = 'surf_start'
      AND table_5.`page.id` = 'END' THEN table_5.`page.id`
      ELSE NULL
    END AS _expr_7,
    table_5.chapter_topics,
    table_5.doc_topics,
    table_5.`read.utm.content`,
    table_5.`read.utm.term`,
    table_5.`read.utm.campaign`,
    table_5.`read.utm.medium`,
    table_5.`read.utm.source`,
    table_5.`agent.browser.version`,
    table_5.`agent.browser.name`,
    table_5.`agent.os.version`,
    table_5.`agent.os.name`,
    table_5.`agent.referer.type`,
    table_5.`agent.referer.label`,
    table_5.`agent.location.state`,
    table_5.`agent.device.type`,
    table_5.`agent.source`,
    table_5.`agent.location.country`,
    table_5.`story.author.id`,
    table_5.`reader.id`,
    table_5.company,
    table_5.`page.immerse_page_group_id`,
    table_5.`page.immerse_page_index`
  FROM
    table_5
    LEFT OUTER JOIN uc_production.dbt.int_banned_ips AS bi ON bi.ip = table_5.`agent.ip`
    AND (
      bi.company_id = table_5.`story.company.id`
      OR bi.scope = 'Global'
    )
  WHERE
    bi.ip IS NULL
),
ana AS (
  SELECT
    `read.id`,
    `story.tenant`,
    `story.id`,
    `story.personalisation.id`,
    `page.id`,
    read_date,
    FIRST_VALUE(company) AS team_id,
    FIRST_VALUE(`reader.id`) AS reader_id,
    FIRST_VALUE(`story.author.id`) AS story_author_id,
    FIRST_VALUE(`agent.location.country`) AS agent_location_country,
    FIRST_VALUE(`agent.source`) AS agent_source,
    FIRST_VALUE(`agent.device.type`) AS agent_device_type,
    FIRST_VALUE(`agent.location.state`) AS agent_location_state,
    FIRST_VALUE(`agent.referer.label`) AS agent_referer_label,
    FIRST_VALUE(`agent.referer.type`) AS agent_referer_type,
    FIRST_VALUE(`agent.os.name`) AS agent_os_name,
    FIRST_VALUE(`agent.os.version`) AS agent_os_version,
    FIRST_VALUE(`agent.browser.name`) AS agent_browser_name,
    FIRST_VALUE(`agent.browser.version`) AS agent_browser_version,
    FIRST_VALUE(`read.utm.source`) AS read_utm_source,
    FIRST_VALUE(`read.utm.medium`) AS read_utm_medium,
    FIRST_VALUE(`read.utm.campaign`) AS read_utm_campaign,
    FIRST_VALUE(`read.utm.term`) AS read_utm_term,
    FIRST_VALUE(`read.utm.content`) AS read_utm_content,
    FIRST_VALUE(doc_topics) AS doc_topics,
    FIRST_VALUE(chapter_topics) AS chapter_topics,
    COUNT(*) AS number_of_events,
    array_agg(DISTINCT _expr_7) AS distinct_surf_pages_read,
    array_agg(DISTINCT _expr_6) AS distinct_immerse_pages_read_v2,
    COALESCE(
      SUM(
        case
          when type = 'surf' then 1
        end
      ),
      0
    ) > 0 AS is_read,
    COALESCE(
      SUM(
        case
          when type = 'surf' then coalesce(duration, 0)
        end
      ),
      0
    ) AS surf_time_ms,
    COALESCE(
      SUM(
        case
          when type in (
            'immersion',
            'immersion_viewed',
            'immerse_page_turn'
          ) then coalesce(duration, 0)
        end
      ),
      0
    ) AS immerse_time_ms
  FROM
    table_4
  GROUP BY
    `read.id`,
    `story.tenant`,
    `story.id`,
    `story.personalisation.id`,
    `page.id`,
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
    ana.`story.id`,
    ana.`story.personalisation.id`,
    ana.`page.id`,
    ana.`story.tenant`,
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
      (
        COALESCE(
          SUM(
            COALESCE(
              COALESCE(ana.surf_time_ms, 0) + COALESCE(ana.immerse_time_ms, 0),
              0
            )
          ),
          0
        ) / 1000
      ),
      0
    ) AS time_spent,
    COALESCE(SUM(ana.number_of_events), 0) AS total_number_of_events
  FROM
    ana
    LEFT OUTER JOIN table_0 ON ana.`story.id` = table_0.chapter_story_id
    AND ana.`page.id` = table_0.chapter_id
    AND ana.`story.tenant` = table_0.tenant
  GROUP BY
    ana.read_date,
    ana.reader_id,
    ana.`story.id`,
    ana.`story.personalisation.id`,
    ana.`page.id`,
    ana.`story.tenant`,
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
    `story.id`,
    `story.personalisation.id`,
    `page.id`,
    `story.tenant`,
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
    (time_spent / array_size(read_pages_array)) AS dts,
    log((time_spent / array_size(read_pages_array)) + 1) AS log_dts,
    (array_size(read_pages_array) / chapter_pages) AS dcp_without_normalisation,
    CASE
      WHEN (array_size(read_pages_array) / chapter_pages) > 1 THEN 1
      ELSE (array_size(read_pages_array) / chapter_pages)
    END AS dcp_non_adjusted,
    CASE
      WHEN (array_size(read_pages_array) / chapter_pages) > 1 THEN 1
      ELSE (array_size(read_pages_array) / chapter_pages)
    END * log10(chapter_pages + 1) AS dcp,
    (
      total_number_of_events / array_size(read_pages_array)
    ) AS dee,
    log(
      (
        total_number_of_events / array_size(read_pages_array)
      ) + 1
    ) AS log_dee
  FROM
    table_3
),
table_2 AS (
  SELECT
    reader_id,
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
    `story.tenant`,
    `page.id`,
    `story.personalisation.id`,
    `story.id`,
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
  table_2.`story.id` AS story_id,
  table_2.`story.personalisation.id` AS story_personalisation_id,
  table_2.`page.id` AS chapter_id,
  table_2.`story.tenant` AS tenant,
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
  (
    (table_2.log_dts - table_2._expr_4) / (table_2._expr_5 - table_2._expr_4)
  ) AS norm_dts,
  (
    (table_2.dcp - table_2._expr_2) / (table_2._expr_3 - table_2._expr_2)
  ) AS norm_dcp,
  (
    (table_2.log_dee - table_2._expr_0) / (table_2._expr_1 - table_2._expr_0)
  ) AS norm_dee,
  (
    (
      (table_2.log_dts - table_2._expr_4) / (table_2._expr_5 - table_2._expr_4)
    ) + (
      (table_2.dcp - table_2._expr_2) / (table_2._expr_3 - table_2._expr_2)
    ) + (
      (table_2.log_dee - table_2._expr_0) / (table_2._expr_1 - table_2._expr_0)
    )
  ) * 100 AS engagement_score
FROM
  table_2
  LEFT OUTER JOIN uc_production.aai.int_reader_accounts AS ira ON ira.reader_id = table_2.reader_id
  AND ira.doc_id = table_2.`story.id`
  AND ira.personalisation_id = table_2.`story.personalisation.id`
  AND ira.team_id = table_2.team_id
  AND ira.tenant = table_2.`story.tenant`
ORDER BY
  engagement_score DESC

-- Generated by PRQL compiler version:0.13.12 (https://prql-lang.org)
