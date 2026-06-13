FROM part
|> JOIN partsupp ON p_partkey = ps_partkey
|> JOIN supplier ON s_suppkey = ps_suppkey
|> JOIN nation   ON s_nationkey = n_nationkey
|> JOIN region   ON n_regionkey = r_regionkey
|> WHERE p_size = 15 
   AND p_type LIKE '%BRASS' 
   AND r_name = 'EUROPE'
|> EXTEND MIN(ps_supplycost) OVER(PARTITION BY p_partkey) AS min_cost_per_part
|> WHERE ps_supplycost = min_cost_per_part
|> SELECT s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment
|> ORDER BY s_acctbal DESC, n_name, s_name, p_partkey
|> LIMIT 100;

from |> join on = where and like extend min () over partitionby as select , orderby desc limit ;

n1 = 20
N1 = 54

part partsupp p_partkey ps_partkey supplier s_suppkey ps_suppkey nation s_nationkey n_nationkey region n_regionkey r_regionkey p_size 15 p_type '%BRASS' r_name 'EUROPE' ps_supplycost min_cost_per_part s_acctbal s_name n_name p_mfgr s_address s_phone s_comment 100

n2 = 29
N2 = 37
