from c = customer
join side:left o = orders (c.c_custkey == o.o_custkey && !(o.o_comment ~= "special.*requests"))
group c.c_custkey (
  aggregate {
    c_count = (o.o_orderkey != null | sum)
  }
)
group c_count (
  aggregate {
    custdist = count c_custkey
  }
)
sort {-custdist, -c_count}