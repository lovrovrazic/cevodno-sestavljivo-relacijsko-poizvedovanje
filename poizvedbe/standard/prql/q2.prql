let min_cost = (
  from ps=partsupp
  join s=supplier (ps.ps_suppkey == s.s_suppkey)
  join n=nation (s.s_nationkey == n.n_nationkey)
  join r=region (n.n_regionkey == r.r_regionkey)
  filter r.r_name == "EUROPE"
  group ps.ps_partkey (
    aggregate {min_ps_supplycost = min ps.ps_supplycost}
  )
)
from p = part
join ps = partsupp (p.p_partkey == ps.ps_partkey)
join s = supplier (ps.ps_suppkey == s.s_suppkey)
join n = nation (s.s_nationkey == n.n_nationkey)
join r = region (n.n_regionkey == r.r_regionkey)
join mc = min_cost (mc.ps_partkey == p.p_partkey && ps.ps_supplycost == mc.min_ps_supplycost)
filter p.p_size == 15
filter p.p_type ~= ".*BRASS$"
filter r.r_name == "EUROPE"
select {
  s.s_acctbal,
  s.s_name,
  n.n_name,
  p.p_partkey,
  p.p_mfgr,
  s.s_address,
  s.s_phone,
  s.s_comment
}
sort {-s.s_acctbal, n.n_name, s.s_name, p.p_partkey}
take 100

-- ------------------------------------------------------------------------

from p=part
join ps=partsupp (p.p_partkey == ps.ps_partkey)
join s=supplier (ps.ps_suppkey == s.s_suppkey)
join n=nation (s.s_nationkey == n.n_nationkey)
join r=region (n.n_regionkey == r.r_regionkey)
group p.p_partkey (
  window (
    derive {min_ps_supplycost = min ps.ps_supplycost}
  )
)
filter ps.ps_supplycost == min_ps_supplycost
filter p.p_size == 15
filter p.p_type ~= ".*BRASS$"
filter r.r_name == "EUROPE"
select {
  s.s_acctbal,
  s.s_name,
  n.n_name,
  p.p_partkey,
  p.p_mfgr,
  s.s_address,
  s.s_phone,
  s.s_comment
}
sort {-s.s_acctbal, n.n_name, s.s_name, p.p_partkey}
take 100