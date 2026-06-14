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


from = join : () == && ! ~= group aggregate . {} != | sum sort , - count

n1 = 20
N1 = 36

c customer side left o orders c_custkey o_custkey o_comment "special.*requests" c_count o_orderkey null custdist

n2 = 14
N2 = 23
