-- create or replace table uc_production.analytics.engagement_score_gold
-- using delta
-- partitioned by (year_day)
-- as
SET use_cached_result = false;
FROM uc_production.analytics.silver
|> WHERE year = 2026 and month = 6 and day = 15 and tenant = 'team'
|> AS e
|> INNER JOIN (
     FROM (
       SELECT
         id,
         title,
         created,
         company,
         tenant_name,
         doc_topics,
         explode_outer(chapter_from_json) as chapter
       FROM (
         FROM uc_production.hevo.mongo_flipbooks
         |> WHERE deleted IS FALSE
         |> SELECT
           _id AS id,
           title,
           created,
           company,
           __turtl__tenant_name AS tenant_name,
           from_json(topics, 'array<string>') AS doc_topics,
           CASE
             WHEN publishedpages = '[]' OR isnull(publishedpages)
               THEN from_json(pages, 'array<struct<_id:string, topics:array<string>>>')
             ELSE from_json(publishedpages, 'array<struct<_id:string, topics:array<string>>>')
           END AS chapter_from_json
       )
     )
     |> SELECT
          id,
          title,
          created,
          company,
          tenant_name,
          doc_topics,
          chapter._id AS chapter_id,
          chapter.topics AS chapter_topics
   ) d
   ON d.id = e.`story.id`
   AND (d.chapter_id = e.`page.id` OR d.chapter_id IS NULL)
|> LEFT JOIN uc_production.hevo.mongo_personalisations p
     ON p.flipbook = e.`story.id`
     AND p._id = e.`story.personalisation.id`
|> WHERE e.`page.id` != 'COOKIE'
     AND e.`agent.ip` NOT IN (
       FROM uc_production.dbt.int_banned_ips
       |> WHERE company_id = e.`story.company.id`
            OR scope = 'Global'
       |> SELECT ip
     )
     AND (p.deleted IS NULL OR p.deleted IS FALSE)
|> EXTEND date_format(e.`tracker.timestamp`, 'yyyy-MM-dd') AS read_date
|> AGGREGATE
     first(d.company) AS team_id,
     first(e.`reader.id`) AS reader_id,
     first(e.`story.author.id`) AS story_author_id,
     first(e.`agent.location.country`) AS agent_location_country,
     first(e.`agent.source`) AS agent_source,
     first(e.`agent.device.type`) AS agent_device_type,
     first(e.`agent.location.state`) AS agent_location_state,
     first(e.`agent.referer.label`) AS agent_referer_label,
     first(e.`agent.referer.type`) AS agent_referer_type,
     first(e.`agent.os.name`) AS agent_os_name,
     first(e.`agent.os.version`) AS agent_os_version,
     first(e.`agent.browser.name`) AS agent_browser_name,
     first(e.`agent.browser.version`) AS agent_browser_version,
     first(e.`read.utm.source`) AS read_utm_source,
     first(e.`read.utm.medium`) AS read_utm_medium,
     first(e.`read.utm.campaign`) AS read_utm_campaign,
     first(e.`read.utm.term`) AS read_utm_term,
     first(e.`read.utm.content`) AS read_utm_content,
     first(d.doc_topics) AS doc_topics,
     first(d.chapter_topics) AS chapter_topics,
     count(*) AS number_of_events,
     coalesce(
       sum(CASE WHEN e.type = 'surf' THEN coalesce(e.duration, 0) END),
       0
     ) AS surf_time_ms,
     coalesce(
       sum(
         CASE
           WHEN e.type IN ('immersion', 'immersion_viewed', 'immerse_page_turn')
             THEN coalesce(e.duration, 0)
         END
       ),
       0
     ) AS immerse_time_ms,
     array_agg(
       DISTINCT CASE
         WHEN e.type = 'immersion'
           OR e.type = 'surf'
           OR (e.type = 'surf_start' AND e.`page.id` = 'END')
           THEN e.`page.id`
       END
     ) AS distinct_surf_pages_read,
     array_agg(
       DISTINCT CASE
         WHEN e.type = 'immersion_start'
           OR e.type = 'immerse_page_turn'
           THEN concat(
             e.`page.id`,
             '_',
             coalesce(e.`page.immerse_page_group_id`, 'unknown'),
             '_',
             coalesce(e.`page.immerse_page_index`, 'unknown')
           )
       END
     ) AS distinct_immerse_pages_read_v2,
     coalesce(count(CASE WHEN e.type = 'surf' THEN 1 END) > 0, false) AS is_read
   GROUP BY
     e.`read.id`,
     e.`story.tenant`,
     e.`story.id`,
     e.`story.personalisation.id`,
     e.`page.id`,
     read_date
|> WHERE is_read = true
|> AS ana
|> LEFT JOIN (
     FROM uc_production.default.doc_features
     |> SELECT
          tenant,
          id AS story_id,
          explode(num_all_pages_per_surf) AS (chapter_id, chapter_pages)
   ) chapter_pages
   ON ana.`story.id` = chapter_pages.story_id
   AND ana.`page.id` = chapter_pages.chapter_id
   AND ana.`story.tenant` = chapter_pages.tenant
|> AGGREGATE
     array_distinct(
       flatten(
         flatten(
           array(
             array_agg(distinct_surf_pages_read),
             array_agg(distinct_immerse_pages_read_v2)
           )
         )
       )
     ) AS read_pages_array,
     coalesce(sum(coalesce(surf_time_ms, 0) + coalesce(immerse_time_ms, 0)) / 1000, 0) AS time_spent,
     sum(number_of_events) AS total_number_of_events
   GROUP BY
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
     chapter_pages.chapter_pages
|> EXTEND array_size(read_pages_array) AS number_of_read_pages
|> EXTEND
     time_spent / number_of_read_pages AS dts,
     log(dts + 1) AS log_dts,
     number_of_read_pages / chapter_pages AS dcp_without_normalisation,
     CASE
       WHEN dcp_without_normalisation > 1 THEN 1
       ELSE dcp_without_normalisation
     END AS dcp_non_adjusted,
     dcp_non_adjusted * log10(chapter_pages + 1) AS dcp,
     total_number_of_events / number_of_read_pages AS dee,
     log(dee + 1) AS log_dee
|> AS met
|> CROSS JOIN (
    SELECT
      13.025439534395558 AS max_log_dts,
      1.9138138523837167 AS max_dcp,
      10.238959288823757 AS max_log_dee,
      0 AS min_log_dts,
      0.01782918846332898 AS min_dcp,
      0.6931471805599453 AS min_log_dee
   ) mmet
|> LEFT JOIN uc_production.aai.int_reader_accounts ira
     ON ira.reader_id = met.reader_id
     AND ira.doc_id = met.`story.id`
     AND ira.personalisation_id <=> met.`story.personalisation.id`
     AND ira.team_id = met.team_id
     AND ira.tenant = met.`story.tenant`
|> EXTEND
     (log_dts - mmet.min_log_dts) / (mmet.max_log_dts - mmet.min_log_dts) AS norm_dts,
     (dcp - mmet.min_dcp) / (mmet.max_dcp - mmet.min_dcp) AS norm_dcp,
     (log_dee - mmet.min_log_dee) / (mmet.max_log_dee - mmet.min_log_dee) AS norm_dee,
     (norm_dts + norm_dcp + norm_dee) * 100 AS engagement_score
|> SELECT
     read_date AS year_day,
     ira.reader_id,
     `story.id` AS story_id,
     `story.personalisation.id` AS story_personalisation_id,
     `page.id` AS chapter_id,
     `story.tenant` AS tenant,
     met.team_id,
     ira.company_key,
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
     norm_dts,
     norm_dcp,
     norm_dee,
     engagement_score
|> ORDER BY engagement_score DESC;
