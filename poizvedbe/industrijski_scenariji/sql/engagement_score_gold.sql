-- create or replace table uc_production.analytics.engagement_score_gold 
-- using delta
-- partitioned by (year_day)
-- as (
SET use_cached_result = false;
with
  docs as (
    select
      *
    from
      (
        select
          _id as id,
          title,
          created,
          company,
          __turtl__tenant_name as tenant_name,
          from_json(topics, 'array<string>') doc_topics,
          explode_outer(
              case
                  when
                      publishedpages = '[]' or isnull(publishedpages) then
                      from_json(pages, 'array<struct<_id:string, topics:array<string>>>')
                  else
                      from_json(publishedpages, 'array<struct<_id:string, topics:array<string>>>')
              end
          ) as chapter,
          chapter._id as chapter_id,
          chapter.topics as chapter_topics
        from
          uc_production.hevo.mongo_flipbooks
        where
          deleted is false
      )
  ),
  gold_metrics_chapters as (
    select
      `read.id` as read_id,
      `story.tenant` as tenant,
      `story.id` as story_id,
      `story.personalisation.id` as story_personalisation_id,
      `page.id` as chapter_id,
      date_format(`tracker.timestamp`, 'yyyy-MM-dd') as read_date,
      first(d.company) as team_id,
      first(`reader.id`) as reader_id,
      first(`story.author.id`) as story_author_id,
      first(`agent.location.country`) as agent_location_country,
      first(`agent.source`) as agent_source,
      first(`agent.device.type`) as agent_device_type,
      first(`agent.location.state`) as agent_location_state,
      first(`agent.referer.label`) as agent_referer_label,
      first(`agent.referer.type`) as agent_referer_type,
      first(`agent.os.name`) as agent_os_name,
      first(`agent.os.version`) as agent_os_version,
      first(`agent.browser.name`) as agent_browser_name,
      first(`agent.browser.version`) as agent_browser_version,
      first(`read.utm.source`) as read_utm_source,
      first(`read.utm.medium`) as read_utm_medium, 
      first(`read.utm.campaign`) as read_utm_campaign, 
      first(`read.utm.term`) as read_utm_term, 
      first(`read.utm.content`) as read_utm_content,
      first(d.doc_topics) as doc_topics,
      first(d.chapter_topics) as chapter_topics,
      count(*) as number_of_events,
      coalesce(
        sum(
          case
            when e.type = 'surf' then coalesce(e.duration, 0)
          end
        ),
        0
      ) as surf_time_ms,
      coalesce(
        sum(
          case
            when e.type in ('immersion', 'immersion_viewed', 'immerse_page_turn')
            then coalesce(e.duration, 0)
          end
        ),
        0
      ) as immerse_time_ms,
      array_agg(distinct
        case
          when
            e.type = 'immersion'
            or e.type = 'surf'
            or (
              e.type = 'surf_start'
              and `page.id` = 'END'
            )
          then
            `page.id`
        end
      ) as distinct_surf_pages_read,
      array_agg(distinct
        case
          when
            e.type = 'immersion_start'
            or e.type = 'immerse_page_turn'
          then
            concat(
              `page.id`,
              '_',
              coalesce(`page.immerse_page_group_id`, 'unknown'),
              '_',
              coalesce(`page.immerse_page_index`, 'unknown')
            )
        end
      ) as distinct_immerse_pages_read_v2,
      (
        coalesce(
          count(
            case
              when e.type = 'surf' then 1
            end
          ) > 0,
          false
        )
      ) as is_read
    from
      uc_production.analytics.silver e
        inner join docs d
          on d.id = e.`story.id`
          and (d.chapter_id = e.`page.id` or d.chapter_id is null)
        left join uc_production.hevo.mongo_personalisations p
          on p.flipbook = e.`story.id`
          and p._id = e.`story.personalisation.id`
    where
      `page.id` != 'COOKIE'
      and e.`agent.ip` not in (
        select
          ip
        from
          uc_production.dbt.int_banned_ips
        where
          company_id = e.`story.company.id`
          or scope = 'Global'
      )
      and (p.deleted is null or p.deleted is false)
      and year = 2026 and month = 6 and day = 15 and tenant = 'team'
    group by
      1, 2, 3, 4, 5, 6
    having
      is_read = true
  ),
  chapter_pages as (
    select
      tenant,
      id as story_id,
      explode(num_all_pages_per_surf) as (chapter_id, chapter_pages)
    from
      uc_production.default.doc_features
  ),
  reads_query as (
    select
      read_date,
      ana.tenant,
      team_id,
      ana.story_id,
      story_personalisation_id,
      ana.chapter_id,
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
      reader_id,
      chapter_pages,
      surf_time_ms,
      immerse_time_ms,
      distinct_surf_pages_read,
      distinct_immerse_pages_read_v2,
      number_of_events
    from
      gold_metrics_chapters as ana 
      left join chapter_pages 
        on ana.story_id = chapter_pages.story_id 
        and ana.chapter_id = chapter_pages.chapter_id
        and ana.tenant = chapter_pages.tenant
  ),
  metrics as (
    select
      read_date as year_day,
      reader_id,
      story_id,
      story_personalisation_id,
      chapter_id,
      tenant,
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
      array_distinct(flatten(flatten(array(
        array_agg(distinct_surf_pages_read),
        array_agg(distinct_immerse_pages_read_v2)
      )))
      ) as read_pages_array,
      array_size(read_pages_array) as number_of_read_pages,
      coalesce(
        (sum(coalesce(surf_time_ms, 0) + coalesce(immerse_time_ms, 0)) / 1000), 0
      ) as time_spent,
      chapter_pages,
      time_spent / number_of_read_pages as dts,
      log(dts + 1) as log_dts,
      number_of_read_pages / chapter_pages as dcp_without_normalisation,
      case
        when dcp_without_normalisation > 1 then 1
        else dcp_without_normalisation
      end as dcp_non_adjusted,
      dcp_non_adjusted * log10(chapter_pages + 1) as dcp,
      sum(number_of_events) / number_of_read_pages as dee,
      log(dee + 1) as log_dee
    from
      reads_query
    group by
      year_day,
      tenant,
      team_id,
      reader_id,
      story_id,
      story_personalisation_id,
      chapter_id,
      chapter_pages,
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
      chapter_topics
  ),
  max_metrics as (
    select
      13.025439534395558 as max_log_dts,
      1.9138138523837167 as max_dcp,
      10.238959288823757 as max_log_dee,
      0 as min_log_dts,
      0.01782918846332898 as min_dcp,
      0.6931471805599453 as min_log_dee
  ),
  eng_score as (
    select
      year_day,
      met.reader_id,
      story_id,
      story_personalisation_id,
      chapter_id,
      met.tenant,
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
      (log_dts - mmet.min_log_dts) / (mmet.max_log_dts - mmet.min_log_dts) as norm_dts,
      (dcp - mmet.min_dcp) / (mmet.max_dcp - mmet.min_dcp) as norm_dcp,
      (met.log_dee - mmet.min_log_dee) / (mmet.max_log_dee - mmet.min_log_dee) as norm_dee,
      (norm_dts + norm_dcp + norm_dee) * 100 as engagement_score
    from
      metrics as met,
      max_metrics as mmet
    left join uc_production.aai.int_reader_accounts ira on ira.reader_id = met.reader_id 
      and ira.doc_id = met.story_id
      and ira.personalisation_id <=> met.story_personalisation_id
      and ira.team_id = met.team_id
      and ira.tenant = met.tenant
  )
select
  *
from
  eng_score
ORDER BY engagement_score DESC;
-- )


 with as () select from , from_json explode_outer case end when then = or else isnull where is . date_format first count coalesce sum array_agg distinct in and array_size > innerjoin on leftjoin != not groupby having explode array_distinct flatten array / + log log10 - * <=> orderby desc concat

n1 = 51
N1 = 656

docs * _id id title created company __turtl__tenant_name tenant_name 'array<string>' topics doc_topics '[]' publishedpages pages 'array<struct<_id:string, topics:array<string>>>' chapter chapter_id chapter_topics uc_production hevo mongo_flipbooks deleted FALSE gold_metrics_chapters read.id read_id story.tenant tenant story.id story_id story.personalisation.id story_personalisation_id d team_id reader.id reader_id story.author.id story_author_id agent.ip agent.location.country agent_location_country agent.source agent_source agent.device.type agent_device_type agent.location.state agent_location_state agent.referer.label agent_referer_label agent.referer.type agent_referer_type agent.os.name agent_os_name agent.os.version agent_os_version agent.browser.name agent_browser_name agent.browser.version agent_browser_version read.utm.source read_utm_source read.utm.medium read_utm_medium read.utm.campaign read_utm_campaign read.utm.term read_utm_term read.utm.content read_utm_content tracker.timestamp number_of_events e type surf duration 0 surf_time_ms immersion immerse_page_turn immersion_viewed immerse_time_ms surf_start END page.id distinct_surf_pages_read immersion_start '_' page.immerse_page_group_id unknown page.immerse_page_index distinct_immerse_pages_read_v2 is_read analytics silver null mongo_personalisations flipbook COOKIE dbt int_banned_ips scope Global story.company.id company_id p year month day 2026 6 15 team 1 , 2 3 4 5 TRUE chapter_pages num_all_pages_per_surf default doc_features reads_query ana read_date year_day read_pages_array number_of_read_pages time_spent dts log_dts dcp_without_normalisation dcp_non_adjusted dcp dee log_dee min_log_dts 13.025.439.534.395.500 max_log_dts 19.138.138.523.837.100 max_dcp 10.238.959.288.823.700 max_log_dee 1.782.918.846.332.890 min_dcp 6.931.471.805.599.450 min_log_dee eng_score met company_key norm_dts norm_dcp norm_dee engagement_score metrics max_metrics mmet aai int_reader_accounts ira doc_id personalisation_id 100

n2 = 165
N2 = 706
