SELECT
    l_returnflag,
    l_linestatus,
    sum(l_quantity) AS sum_qty,
    sum(l_extendedprice) AS sum_base_price,
    sum(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
    sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
    avg(l_quantity) AS avg_qty,
    avg(l_extendedprice) AS avg_price,
    avg(l_discount) AS avg_disc,
    count(*) AS count_order
FROM
    lineitem
WHERE
    l_shipdate <= CAST('1998-09-02' AS date)
GROUP BY
    l_returnflag,
    l_linestatus
ORDER BY
    l_returnflag,
    l_linestatus;



, AS sum avg () - + <= CAST count * date ;

n1 = 18
N1 = 50

l_returnflag l_linestatus l_quantity l_extendedprice sum_qty sum_base_price sum_disc_price sum_charge avg_qty avg_price avg_disc count_order l_shipdate 1 l_tax * '1998-09-02' l_discount lineitem
 
n2 = 19
N2 = 31
