SELECT
    s_acctbal,
    s_name,
    n_name,
    p_partkey,
    p_mfgr,
    s_address,
    s_phone,
    s_comment
FROM
    part,
    supplier,
    partsupp,
    nation,
    region
WHERE
    p_partkey = ps_partkey
    AND s_suppkey = ps_suppkey
    AND p_size = 15
    AND p_type LIKE '%BRASS'
    AND s_nationkey = n_nationkey
    AND n_regionkey = r_regionkey
    AND r_name = 'EUROPE'
    AND ps_supplycost = (
        SELECT
            min(ps_supplycost)
        FROM
            partsupp,
            supplier,
            nation,
            region
        WHERE
            p_partkey = ps_partkey
            AND s_suppkey = ps_suppkey
            AND s_nationkey = n_nationkey
            AND n_regionkey = r_regionkey
            AND r_name = 'EUROPE')
ORDER BY
    s_acctbal DESC,
    n_name,
    s_name,
    p_partkey
LIMIT 100;


select , from where = and like () min orderby desc limit ;

n1 = 13
N1 = 54

s_acctbal s_name n_name p_partkey p_mfgr s_address s_phone s_comment part supplier partsupp nation region ps_partkey s_suppkey ps_suppkey p_size 15 p_type '%BRASS' s_nationkey n_nationkey n_regionkey r_regionkey r_name 'EUROPE' ps_supplycost 100

n2 = 28
N2 = 48
