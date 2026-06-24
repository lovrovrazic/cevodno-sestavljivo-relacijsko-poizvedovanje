
from lineitem
filter l_shipdate >= @1996-01-01 && l_shipdate < @1996-04-01
group l_suppkey (
  aggregate {
    total_revenue = sum (l_extendedprice * (1 - l_discount))
  }
)
select {supplier_no = l_suppkey, total_revenue}
derive max_revenue = (max total_revenue)
filter total_revenue == max_revenue
join supplier (s_suppkey == supplier_no)
select {
  s_suppkey,
  s_name,
  s_address,
  s_phone,
  total_revenue
}
sort s_suppkey