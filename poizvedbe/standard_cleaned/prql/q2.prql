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

from = join () . == group window derive min {} filter ~= select , sort - take

n1 = 18
N1 = 75


p part ps partsupp p_partkey ps_partkey s supplier ps_suppkey s_suppkey n nation s_nationkey n_nationkey r region n_regionkey r_regionkey min_ps_supplycost p_size 15 p_type ".*BRASS$" r_name "EUROPE" s_acctbal s_name n_name p_mfgr s_address s_phone s_comment 100

n2 = 33
N2 = 64
