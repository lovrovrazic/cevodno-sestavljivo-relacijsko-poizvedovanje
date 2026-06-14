FROM supplier
|> JOIN lineitem l1 ON s_suppkey = l1.l_suppkey
|> JOIN orders ON o_orderkey = l1.l_orderkey
|> JOIN nation ON s_nationkey = n_nationkey
|> WHERE o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND n_name = 'SAUDI ARABIA'
|> SEMI JOIN lineitem l2
    ON l2.l_orderkey = l1.l_orderkey
    AND l2.l_suppkey != l1.l_suppkey
|> ANTI JOIN lineitem l3
    ON l3.l_orderkey = l1.l_orderkey
    AND l3.l_suppkey != l1.l_suppkey
    AND l3.l_receiptdate > l3.l_commitdate
|> AGGREGATE COUNT(*) AS numwait
   GROUP BY s_name
|> ORDER BY numwait DESC, s_name
|> LIMIT 100;