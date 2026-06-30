SELECT
    c_count,
    count(*) AS custdist
FROM (
    SELECT
        c_custkey,
        count(o_orderkey)
    FROM
        customer
    LEFT OUTER JOIN
        orders
        ON c_custkey = o_custkey
        AND o_comment NOT LIKE '%special%requests%'
    GROUP BY
        c_custkey
    ) AS c_orders (c_custkey, c_count)
GROUP BY
    c_count
ORDER BY
    custdist DESC,
    c_count DESC;


select , count () * as from leftouterjoin on = and not like groupby orderby desc ;

n1 = 17
N1 = 28

c_count custdist c_custkey o_orderkey customer orders o_custkey o_comment '%special%requests%' c_orders 

n2 = 10
N2 = 17
