FROM lineitem
|> WHERE l_shipdate <= CAST('1998-09-02' AS date)
|> AGGREGATE
     SUM(l_quantity) AS sum_qty,
     SUM(l_extendedprice) AS sum_base_price,
     SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
     SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
     AVG(l_quantity) AS avg_qty,
     AVG(l_extendedprice) AS avg_price,
     AVG(l_discount) AS avg_disc,
     COUNT(*) AS count_order
   GROUP BY l_returnflag, l_linestatus
|> ORDER BY l_returnflag, l_linestatus;


FROM |> WHERE <= CAST AS AGGREGATE SUM () , * - + AVG COUNT GROUPBY ORDERBY ;

n1 = 18
N1 = 54

date lineitem l_shipdate '1998-09-02' l_quantity sum_qty l_extendedprice sum_base_price l_discount sum_disc_price l_tax sum_charge avg_qty avg_price avg_disc count_order * 1 l_returnflag l_linestatus

n2 = 20
N2 = 30
