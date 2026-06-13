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


from filter <= {} - +  = * () , group aggregate sum average count sort

n1 = 16
N1 = 42

lineitem l_shipdate @1998-12-01 l_extendedprice 1 l_discount l_tax l_returnflag l_linestatus sum_qty l_quantity sum_base_price sum_disc_price sum_charge avg_qty avg_price avg_disc count_order

n2 = 18
N2 = 28
