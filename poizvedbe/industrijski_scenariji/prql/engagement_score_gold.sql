from (
  from uc_production.hevo.mongo_flipbooks
  filter (deleted == false)
  select {
    id = _id,
    title,
    created,
    company,
    tenant_name = __turtl__tenant_name,
    doc_topics = s"from_json(topics, 'array<string>')",
    publishedpages,
    chapter_from_json = case [
      publishedpages == '[]' || publishedpages == null => s"from_json(pages, 'array<struct<_id:string, topics:array<string>>>')",
      true => s"from_json(publishedpages, 'array<struct<_id:string, topics:array<string>>>')"
    ]
  }
)
into cfj
from cfj
derive {
  chapter = s"explode_outer({chapter_from_json})"
}
select !{
  publishedpages,
  chapter_from_json
}
into c
from c
derive {
  chapter_id = s"chapter._id",
  chapter_topics = s"chapter.topics"
}
select !{
  chapter
}
into d

from e = uc_production.analytics.silver
filter (year == 2026 && month == 6 && day == 15 && tenant == 'team')
derive {
  story_id = s"`story.id`",
  story_personalisation_id = s"`story.personalisation.id`",
  story_company_id = s"`story.company.id`",
  story_tenant = s"`story.tenant`",
  page_id = s"`page.id`",
  e_type = s"`type`",
  read_id = s"`read.id`",
  duration,
  tracker_timestamp = s"`tracker.timestamp`",
  page_immerse_page_group_id = s"`page.immerse_page_group_id`",
  page_immerse_page_index = s"`page.immerse_page_index`"
}
join side:inner d (d.id == story_id && (d.chapter_id == page_id || d.chapter_id == null))
join side:left p = uc_production.hevo.mongo_personalisations (p.flipbook == story_id && p._id == story_personalisation_id)
filter (page_id != 'COOKIE' && (p.deleted == null || p.deleted == false))
join side:left bi = uc_production.dbt.int_banned_ips (bi.company_id == story_company_id || bi.scope == 'Global')
filter (bi.ip == null)
derive {
  read_date = s"date_format({tracker_timestamp}, 'yyyy-MM-dd')",
  surf_page_read = case [
    e_type == 'immersion' || e_type == 'surf' || (e_type == 'surf_start' && page_id == 'END') => page_id
  ],
  immerse_page_read = case [
    e_type == 'immersion_start' || e_type == 'immerse_page_turn' => s"concat({page_id}, '_', coalesce({page_immerse_page_group_id}, 'unknown'), '_', coalesce({page_immerse_page_index}, 'unknown'))"
  ]
}
group {read_id, story_tenant, story_id, story_personalisation_id, page_id, read_date} (
  aggregate {
    team_id = first d.company,
    reader_id = first s"`reader.id`",
    story_author_id = first s"`story.author.id`",
    agent_location_country = first s"`agent.location.country`",
    agent_source = first s"`agent.source`",
    agent_device_type = first s"`agent.device.type`",
    agent_location_state = first s"`agent.location.state`",
    agent_referer_label = first s"`agent.referer.label`",
    agent_referer_type = first s"`agent.referer.type`",
    agent_os_name = first s"`agent.os.name`",
    agent_os_version = first s"`agent.os.version`",
    agent_browser_name = first s"`agent.browser.name`",
    agent_browser_version = first s"`agent.browser.version`",
    read_utm_source = first s"`read.utm.source`",
    read_utm_medium = first s"`read.utm.medium`",
    read_utm_campaign = first s"`read.utm.campaign`",
    read_utm_term = first s"`read.utm.term`",
    read_utm_content = first s"`read.utm.content`",
    doc_topics = first d.doc_topics,
    chapter_topics = first d.chapter_topics,
    number_of_events = count {},
    surf_time_ms = ((sum (case [e_type == "surf" => e.duration ?? 0])) ?? 0),
    immerse_time_ms = ((sum (case [(e.e_type | in ['immersion', 'immersion_viewed', 'immerse_page_turn']) => e.duration ?? 0])) ?? 0),
    distinct_surf_pages_read = s"array_agg(DISTINCT {surf_page_read})",
    distinct_immerse_pages_read_v2 = s"array_agg(DISTINCT {immerse_page_read})",
    is_read = sum (case [e.e_type == 'surf' => 1]) > 1 ?? false
  }
)
filter is_read == true
into ana

from ana
join side:left chapter_pages = (
  from (s"""
    SELECT 
      tenant,
      id AS chapter_story_id,
      explode(num_all_pages_per_surf) AS (chapter_id, chapter_pages)
    FROM uc_production.default.doc_features
  """)
  select {
    tenant,
    chapter_story_id,
    chapter_id,
    chapter_pages
  }
) (ana.story_id == chapter_pages.chapter_story_id && ana.page_id == chapter_pages.chapter_id && ana.story_tenant == chapter_pages.tenant)
group {
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
  chapter_pages.chapter_pages
} (
  aggregate {
    read_pages_array = s"array_distinct(flatten(flatten(array(array_agg({distinct_surf_pages_read}),array_agg({distinct_immerse_pages_read_v2})))))",
    time_spent = ((sum (surf_time_ms ?? 0 + immerse_time_ms ?? 0) ?? 0) / 1000) ?? 0,
    total_number_of_events = sum number_of_events
  }
)
derive {
  number_of_read_pages = s"array_size({read_pages_array})"
}
derive {
  dts = time_spent / number_of_read_pages,
  log_dts = s"log({dts} + 1)",
  dcp_without_normalisation = number_of_read_pages / chapter_pages.chapter_pages,
  dcp_non_adjusted = case [
    dcp_without_normalisation > 1 => 1,
    true => dcp_without_normalisation
  ],
  dcp = dcp_non_adjusted * s"log10({chapter_pages.chapter_pages}+1)",
  dee = total_number_of_events / number_of_read_pages,
  log_dee = s"log({dee} + 1)"
}
into met

from met
derive {
  max_log_dts = 13.025439534395558,
  max_dcp = 1.9138138523837167,
  max_log_dee = 10.238959288823757,
  min_log_dts = 0,
  min_dcp = 0.01782918846332898,
  min_log_dee = 0.6931471805599453
}
join side:left ira = uc_production.aai.int_reader_accounts (ira.reader_id == met.reader_id && ira.doc_id == met.story_id && ira.personalisation_id == met.story_personalisation_id && ira.team_id == met.team_id && ira.tenant == met.story_tenant)
derive {
  norm_dts = (log_dts - min_log_dts) / (max_log_dts - min_log_dts),
  norm_dcp = (dcp - min_dcp) / (max_dcp - min_dcp),
  norm_dee = (log_dee - min_log_dee) / (max_log_dee - min_log_dee),
  engagement_score = (norm_dts + norm_dcp + norm_dee) * 100
}
select {
     year_day = read_date,
     met.reader_id,
     story_id,
     story_personalisation_id,
     chapter_id = page_id,
     tenant = story_tenant,
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
}
sort {-engagement_score}
