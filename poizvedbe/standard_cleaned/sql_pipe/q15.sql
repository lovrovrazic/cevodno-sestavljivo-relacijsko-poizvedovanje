FROM lineitem
|> WHERE l_shipdate >= CAST('1996-01-01' AS date)
    AND l_shipdate < CAST('1996-04-01' AS date)
|> AGGREGATE SUM(l_extendedprice * (1 - l_discount)) AS total_revenue
    GROUP BY l_suppkey
|> SELECT l_suppkey AS supplier_no, total_revenue
|> EXTEND MAX(total_revenue) OVER() AS max_revenue
|> WHERE total_revenue = max_revenue
|> JOIN supplier ON supplier_no = s_suppkey
|> SELECT s_suppkey, s_name, s_address, s_phone, total_revenue
|> ORDER BY s_suppkey;

from |> where >= cast () as and aggregate sum * - groupby select , extend max over = join on orderby ;

n1 = 23
N1 = 48

lineitem l_shipdate '1996-01-01' date '1996-04-01' l_extendedprice 1 l_discount total_revenue l_suppkey supplier_no max_revenue supplier s_suppkey s_name s_address s_phone 

n2 = 17
N2 = 28
