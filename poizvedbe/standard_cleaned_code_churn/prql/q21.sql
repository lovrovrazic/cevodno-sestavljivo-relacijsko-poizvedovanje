let orders_with_multiple_supps = (
  from lineitem
  group l_orderkey (
    aggregate {
      total_supps = count l_suppkey
    }
  )
  filter total_supps > 1
  select (ms_l_orderkey = l_orderkey)
)
let orders_with_only_one_late_supp = (
  from lineitem
  filter l_receiptdate > l_commitdate
  group l_orderkey (
    aggregate {
      late_supps = count l_suppkey
    }
  )
  filter late_supps == 1
  select (ol_l_orderkey = l_orderkey)
)
from l1 = lineitem
filter l1.l_receiptdate > l1.l_commitdate
join s = supplier (l1.l_suppkey == s.s_suppkey)
join o = orders (l1.l_orderkey == o.o_orderkey)
join n = nation (s.s_nationkey == n.n_nationkey)
filter n.n_name == "SAUDI ARABIA"
filter o.o_orderstatus == "F"
join ms = orders_with_multiple_supps (l1.l_orderkey == ms.ms_l_orderkey)
join ol = orders_with_only_one_late_supp (l1.l_orderkey == ol.ol_l_orderkey)
group (s.s_name) (
  aggregate {
    numwait = count {}
  }
)
sort {-numwait, s.s_name}
take 100