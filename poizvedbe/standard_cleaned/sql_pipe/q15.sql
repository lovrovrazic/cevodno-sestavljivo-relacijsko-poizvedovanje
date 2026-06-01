FROM samples.tpch.lineitem
|> WHERE l_shipdate >= CAST('1996-01-01' AS date)
    AND l_shipdate < CAST('1996-04-01' AS date)
|> AGGREGATE SUM(l_extendedprice * (1 - l_discount)) AS total_revenue
    GROUP BY l_suppkey
|> SELECT l_suppkey AS supplier_no, total_revenue
|> EXTEND MAX(total_revenue) OVER() AS max_revenue
|> WHERE total_revenue = max_revenue
|> JOIN samples.tpch.supplier ON supplier_no = s_suppkey
|> SELECT s_suppkey, s_name, s_address, s_phone, total_revenue
|> ORDER BY s_suppkey;