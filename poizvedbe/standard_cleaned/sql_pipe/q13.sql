FROM customer
|> LEFT OUTER JOIN orders ON c_custkey = o_custkey
   AND o_comment NOT LIKE '%special%requests%'
|> AGGREGATE COUNT(o_orderkey) AS c_count 
   GROUP BY c_custkey
|> AGGREGATE COUNT(*) AS custdist
   GROUP BY c_count
|> ORDER BY custdist DESC, c_count DESC;

from |> leftouterjoin on = and not like aggregate count () as groupby orderby desc , ;

n1 = 17
N1 = 26

customer orders c_custkey o_custkey o_comment '%special%requests%' o_orderkey c_count custdist *

n2 = 10
N2 = 14
