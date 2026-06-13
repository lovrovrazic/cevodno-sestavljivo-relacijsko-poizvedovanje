from lineitem
filter l_shipdate <= @1998-09-02
group {l_returnflag, l_linestatus} (
  aggregate {
    sum_qty = sum l_quantity,
    sum_base_price = sum l_extendedprice,
    sum_disc_price = sum l_extendedprice * (1 - l_discount),
    sum_charge = sum l_extendedprice * (1 - l_discount) * (1 + l_tax),
    avg_qty = average l_quantity,
    avg_price = average l_extendedprice,
    avg_disc = average l_discount,
    count_order = count {}
  }
)
sort {l_returnflag, l_linestatus}