// CREATE statement for doc_stats_timeseries table
// CREATE TABLE uc_production.analytics.doc_stats_timeseries ( id STRING, tenant STRING, tenantId STRING, docId STRING, docTeamId STRING, publishedVersionId STRING, reads INT, readsChange INT, windowStart TIMESTAMP, windowEnd TIMESTAMP, timestamp TIMESTAMP)


const calculateAndUpsertDocStatsQuery = ({ timestampStart, timestampEnd }) => `
  with 
  deleted_persos as (
    select
      _id as personalisation_id
    from 
      uc_production.hevo.mongo_personalisations
    where 
      deleted = true
      and created >= '2023-03-01'
  ),
  docs as (
    select 
      _id as story_id
    from
    uc_production.hevo.mongo_flipbooks
    where
      publishedat > '2023-03-01'
      and deleted = false
  ),
  reads_window as (
    select
      e.story_id,
      first(tenant) as tenant,
      first(story_company_id) as story_company_id,
      coalesce(first(story_publishedVersion), '') as story_publishedVersion,
      count(distinct read_id) filter (where is_read = true) as reads,
      window.start as windowStart,
      window.end as windowEnd
    from
      uc_production.analytics.gold e
    inner join
      docs d on e.story_id = d.story_id
    left join
      deleted_persos dp on e.story_personalisation_id = dp.personalisation_id
    left join 
      uc_production.dbt.int_banned_ips b on e.agent_ip = b.ip 
        and (b.company_id = e.story_company_id or b.scope = 'Global')
    where
      dp.personalisation_id is null
      and b.ip is null
      and e.min_timestamp >= '${timestampStart}'
      and e.min_timestamp < '${timestampEnd}'
    group by
      e.story_id,
      window(min_timestamp, '15 MINUTES')
    having
      reads > 0
  ),
  windows as (
    select 
      story_id,
      windowStart,
      windowEnd
    from 
      reads_window
    group by
      story_id,
      windowStart,
      windowEnd
  ),
  reads_total as (
    select
      w.story_id,
      w.windowEnd,
      count(distinct read_id) as reads
    from 
      windows w
    left join 
      uc_production.analytics.gold e on e.story_id = w.story_id
    left join
      deleted_persos dp on e.story_personalisation_id = dp.personalisation_id
    left join 
      uc_production.dbt.int_banned_ips b on e.agent_ip = b.ip 
        and (b.company_id = e.story_company_id or b.scope = 'Global')
    where
      dp.personalisation_id is null
      and b.ip is null
      and e.min_timestamp < windowEnd
      and e.story_id in (select * from docs)
      and e.is_read is true
    group by
      w.story_id,
      windowEnd
  )
      
  merge into uc_production.analytics.doc_stats_timeseries
  using (
    select
      sha2(concat(string(rw.tenant), string(rw.story_id), string(rw.story_publishedVersion), string(rw.windowStart), string(rw.windowEnd)), 256) as id,
      rw.tenant,
      first(t._id) as tenantId,
      rw.story_id AS docId,
      rw.story_company_id as docTeamId,
      rw.story_publishedVersion as publishedVersionId,
      first(rt.reads) as reads,
      first(rw.reads) as readsChange,
      rw.windowStart as windowStart,
      rw.windowEnd as windowEnd,
      current_timestamp() as timestamp
    from
      reads_window rw
      left join reads_total rt on rt.story_id = rw.story_id and rt.windowEnd = rw.windowEnd
      left join uc_production.hevo.mongo_tenants t on rw.tenant = t.name
    group by
      rw.tenant,
      rw.story_id,
      rw.story_company_id,
      rw.story_publishedVersion,
      rw.windowStart,
      rw.windowEnd
  ) as updates
  on uc_production.analytics.doc_stats_timeseries.id = updates.id
  when not matched 
    then insert *;
`

const calculateDocStatsQuery = ({ timestampStart, timestampEnd }) => `
  with 
  deleted_persos as (
    select
      _id as personalisation_id
    from 
      uc_production.hevo.mongo_personalisations
    where 
      deleted = true
      and created >= '2023-03-01'
  ),
  docs as (
    select 
      _id as story_id
    from
    uc_production.hevo.mongo_flipbooks
    where
      publishedat > '2023-03-01'
      and deleted = false
  ),
  reads_window as (
    select
      e.story_id,
      first(tenant) as tenant,
      first(story_company_id) as story_company_id,
      coalesce(first(story_publishedVersion), '') as story_publishedVersion,
      count(distinct read_id) filter (where is_read = true) as reads,
      window.start as windowStart,
      window.end as windowEnd
    from
      uc_production.analytics.gold e
    inner join
      docs d on e.story_id = d.story_id
    left join
      deleted_persos dp on e.story_personalisation_id = dp.personalisation_id
    left join 
      uc_production.dbt.int_banned_ips b on e.agent_ip = b.ip 
        and (b.company_id = e.story_company_id or b.scope = 'Global')
    where
      dp.personalisation_id is null
      and b.ip is null
      and e.min_timestamp >= '${timestampStart}'
      and e.min_timestamp < '${timestampEnd}'
    group by
      e.story_id,
      window(min_timestamp, '15 MINUTES')
    having
      reads > 0
  ),
  windows as (
    select 
      story_id,
      windowStart,
      windowEnd
    from 
      reads_window
    group by
      story_id,
      windowStart,
      windowEnd
  ),
  reads_total as (
    select
      w.story_id,
      w.windowEnd,
      count(distinct read_id) as reads
    from 
      windows w
    left join 
      uc_production.analytics.gold e on e.story_id = w.story_id
    left join
      deleted_persos dp on e.story_personalisation_id = dp.personalisation_id
    left join
      uc_production.dbt.int_banned_ips b on e.agent_ip = b.ip 
        and (b.company_id = e.story_company_id or b.scope = 'Global')
    where
      dp.personalisation_id is null
      and b.ip is null
      and e.min_timestamp < windowEnd
      and e.is_read is true
    group by
      w.story_id,
      windowEnd
  )

  select
    sha2(concat(string(rw.tenant), string(rw.story_id), string(rw.story_publishedVersion), string(rw.windowStart), string(rw.windowEnd)), 256) as id,
    rw.tenant as tenantName,
    first(t._id) as tenantId,
    rw.story_id AS docId,
    rw.story_company_id as docTeamId,
    rw.story_publishedVersion as publishedVersionId,
    first(rt.reads) as reads,
    first(rw.reads) as readsChange,
    rw.windowStart as windowStart,
    rw.windowEnd as windowEnd,
    current_timestamp() as timestamp
  from
    reads_window rw
    left join reads_total rt on rt.story_id = rw.story_id and rt.windowEnd = rw.windowEnd
    left join uc_production.hevo.mongo_tenants t on rw.tenant = t.name
  group by
    rw.tenant,
    rw.story_id,
    rw.story_company_id,
    rw.story_publishedVersion,
    rw.windowStart,
    rw.windowEnd
`

const getLatestTimestamp = `
  select max(windowEnd) as latestTimestamp
  from uc_production.analytics.doc_stats_timeseries
`

const getLatestInsightsRecordsForLastNHours = forLastNHours => `
select 
	first(dst1.tenant) as tenantName,
	first(dst1.tenantId) as tenantId,
	first(dst1.docId) as docId,
  first(dst1.docTeamId) as docTeamId,
	max(dst1.reads) as reads, 
	max(dst1.windowStart) as windowStart, 
	max(dst1.windowEnd) as windowEnd, 
	max(dst1.timestamp) as timestamp
from uc_production.analytics.doc_stats_timeseries dst1
inner join 
(
  SELECT docId, max(windowEnd) as maxTimestamp
  FROM uc_production.analytics.doc_stats_timeseries
  where timestamp >= (current_timestamp() - INTERVAL '${forLastNHours}' HOUR)
  GROUP BY docId 
) dst2 on dst2.docId = dst1.docId and dst1.windowEnd = dst2.maxTimestamp
group by dst1.docId
`

module.exports = {
  calculateDocStatsQuery,
  calculateAndUpsertDocStatsQuery,
  getLatestTimestamp,
  getLatestInsightsRecordsForLastNHours,
}
