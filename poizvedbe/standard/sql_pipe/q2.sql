FROM samples.tpch.part
|> JOIN samples.tpch.partsupp ON p_partkey = ps_partkey
|> JOIN samples.tpch.supplier ON s_suppkey = ps_suppkey
|> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
|> JOIN samples.tpch.region ON n_regionkey = r_regionkey
|> WHERE p_size = 15
    AND p_type LIKE '%BRASS'
    AND r_name = 'EUROPE'
    AND ps_supplycost = (
        FROM samples.tpch.partsupp
        |> JOIN samples.tpch.supplier ON s_suppkey = ps_suppkey
        |> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
        |> JOIN samples.tpch.region ON n_regionkey = r_regionkey
        |> WHERE p_partkey = ps_partkey
            AND r_name = 'EUROPE'
        |> AGGREGATE MIN(ps_supplycost)
    )
|> SELECT
    s_acctbal,
    s_name,
    n_name,
    p_partkey,
    p_mfgr,
    s_address,
    s_phone,
    s_comment
|> ORDER BY
    s_acctbal DESC,
    n_name,
    s_name,
    p_partkey
|> LIMIT 100;

-- ------------------------------------------------------------------------

FROM samples.tpch.part
|> JOIN samples.tpch.partsupp ON p_partkey = ps_partkey
|> JOIN samples.tpch.supplier ON s_suppkey = ps_suppkey
|> JOIN samples.tpch.nation   ON s_nationkey = n_nationkey
|> JOIN samples.tpch.region   ON n_regionkey = r_regionkey
|> WHERE p_size = 15 
   AND p_type LIKE '%BRASS' 
   AND r_name = 'EUROPE'
|> EXTEND MIN(ps_supplycost) OVER(PARTITION BY p_partkey) AS min_cost_per_part
|> WHERE ps_supplycost = min_cost_per_part
|> SELECT s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment
|> ORDER BY s_acctbal DESC, n_name, s_name, p_partkey
|> LIMIT 100;

-- ------------------------------------------------------------------------

WITH min_supplycost AS (
    FROM samples.tpch.partsupp
    |> JOIN samples.tpch.supplier ON s_suppkey = ps_suppkey
    |> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
    |> JOIN samples.tpch.region ON n_regionkey = r_regionkey
    |> WHERE r_name = 'EUROPE'
    |> AGGREGATE MIN(ps_supplycost) AS min_cost
       GROUP BY ps_partkey
)
FROM samples.tpch.part
|> JOIN samples.tpch.partsupp ON p_partkey = ps_partkey
|> JOIN samples.tpch.supplier ON s_suppkey = ps_suppkey
|> JOIN samples.tpch.nation ON s_nationkey = n_nationkey
|> JOIN samples.tpch.region ON n_regionkey = r_regionkey
|> JOIN min_supplycost ON p_partkey = min_supplycost.ps_partkey
|> WHERE p_size = 15
    AND p_type LIKE '%BRASS'
    AND r_name = 'EUROPE'
    AND ps_supplycost = min_supplycost.min_cost
|> SELECT
    s_acctbal,
    s_name,
    n_name,
    p_partkey,
    p_mfgr,
    s_address,
    s_phone,
    s_comment
|> ORDER BY
    s_acctbal DESC,
    n_name,
    s_name,
    p_partkey
|> LIMIT 100;