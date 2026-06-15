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


from |> join on = . where and > semijoin antijoin != aggregate count () * as groupby orderby desc , limit ;

n1 = 23
N1 = 62

supplier lineitem l1 s_suppkey l_suppkey orders o_orderkey l_orderkey nation s_nationkey n_nationkey o_orderstatus 'F' l_receiptdate l_commitdate n_name 'SAUDI ARABIA' l2 l3 numwait s_name 100

n2 = 22
N2 = 50
