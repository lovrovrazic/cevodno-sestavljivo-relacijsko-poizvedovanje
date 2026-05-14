FROM samples.tpch.supplier
|> JOIN samples.tpch.lineitem l1 ON s_suppkey = l1.l_suppkey
|> JOIN samples.tpch.orders ON o_orderkey = l1.l_orderkey
|> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
|> WHERE o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND EXISTS (
        SELECT *
        FROM samples.tpch.lineitem l2
        WHERE l2.l_orderkey = l1.l_orderkey
            AND l2.l_suppkey <> l1.l_suppkey
    )
    AND NOT EXISTS (
        SELECT *
        FROM samples.tpch.lineitem l3
        WHERE l3.l_orderkey = l1.l_orderkey
            AND l3.l_suppkey <> l1.l_suppkey
            AND l3.l_receiptdate > l3.l_commitdate
    )
    AND n_name = 'SAUDI ARABIA'
|> AGGREGATE COUNT(*) AS numwait GROUP BY s_name
|> ORDER BY numwait DESC, s_name
|> LIMIT 100;

-- ------------------------------------------------------------------------

WITH multi_supp_orders AS (
    FROM samples.tpch.lineitem
    |> AGGREGATE COUNT(DISTINCT l_suppkey) AS supp_cnt
       GROUP BY l_orderkey
    |> WHERE supp_cnt > 1
    |> SELECT l_orderkey
),
late_supp_count AS (
    FROM samples.tpch.lineitem
    |> WHERE l_receiptdate > l_commitdate
    |> AGGREGATE COUNT(DISTINCT l_suppkey) AS late_cnt
       GROUP BY l_orderkey
    |> WHERE late_cnt = 1
    |> SELECT l_orderkey
)
FROM samples.tpch.supplier
|> JOIN samples.tpch.lineitem l1 ON s_suppkey = l1.l_suppkey
|> JOIN samples.tpch.orders ON o_orderkey = l1.l_orderkey
|> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
|> JOIN multi_supp_orders mso ON l1.l_orderkey = mso.l_orderkey
|> JOIN late_supp_count lsc ON l1.l_orderkey = lsc.l_orderkey
|> WHERE o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND n_name = 'SAUDI ARABIA'
|> AGGREGATE COUNT(*) AS numwait GROUP BY s_name
|> ORDER BY numwait DESC, s_name
|> LIMIT 100;

-- ------------------------------------------------------------------------

FROM samples.tpch.supplier
|> JOIN samples.tpch.lineitem l1 ON s_suppkey = l1.l_suppkey
|> JOIN samples.tpch.orders ON o_orderkey = l1.l_orderkey
|> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
|> WHERE o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND n_name = 'SAUDI ARABIA'
|> SEMI JOIN samples.tpch.lineitem l2
    ON l2.l_orderkey = l1.l_orderkey
    AND l2.l_suppkey != l1.l_suppkey
|> ANTI JOIN samples.tpch.lineitem l3
    ON l3.l_orderkey = l1.l_orderkey
    AND l3.l_suppkey != l1.l_suppkey
    AND l3.l_receiptdate > l3.l_commitdate
|> AGGREGATE COUNT(*) AS numwait GROUP BY s_name
|> ORDER BY numwait DESC, s_name
|> LIMIT 100;