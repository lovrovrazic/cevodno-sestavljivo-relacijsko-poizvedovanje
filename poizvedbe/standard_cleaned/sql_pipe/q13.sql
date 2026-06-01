FROM samples.tpch.customer
|> LEFT OUTER JOIN samples.tpch.orders ON c_custkey = o_custkey
   AND o_comment NOT LIKE '%special%requests%'
|> AGGREGATE COUNT(o_orderkey) AS c_count 
   GROUP BY c_custkey
|> AGGREGATE COUNT(*) AS custdist
   GROUP BY c_count
|> ORDER BY custdist DESC, c_count DESC;