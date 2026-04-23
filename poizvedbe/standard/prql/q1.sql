from lineitem
filter l_shipdate <= @1998-12-01 - 90days
derive {
  disc_price = l_extendedprice * (1 - l_discount),
  charge = l_extendedprice * (1 - l_discount) * (1 + l_tax)
}
group {l_returnflag, l_linestatus} (
  aggregate {
    sum_qty = sum l_quantity,
    sum_base_price = sum l_extendedprice,
    sum_disc_price = sum disc_price,
    sum_charge = sum charge,
    avg_qty = average l_quantity,
    avg_price = average l_extendedprice,
    avg_disc = average l_discount,
    count_order = count avg_disc
  }
)
sort {l_returnflag, l_linestatus}