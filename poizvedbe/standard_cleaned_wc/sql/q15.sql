WITH revenue AS (
    SELECT
        l_suppkey AS supplier_no,
        sum(l_extendedprice * (1 - l_discount)) AS total_revenue
    FROM
        lineitem
    WHERE
        l_shipdate >= CAST('1996-01-01' AS date)
        AND l_shipdate < CAST('1996-04-01' AS date)
    GROUP BY
        supplier_no
)
SELECT
    s_suppkey,
    s_name,
    s_address,
    s_phone,
    total_revenue
FROM
    supplier,
    revenue
WHERE
    s_suppkey = supplier_no
    AND total_revenue = (
        SELECT
            max(total_revenue)
        FROM revenue)
ORDER BY
    s_suppkey;


with as () select , sum * - from where >= cast date < groupby = max orderby ;

n1 = 19
N1 = 42

revenue l_suppkey supplier_no l_extendedprice 1 l_discount total_revenue lineitem l_shipdate '1996-01-01' '1996-04-01' s_suppkey s_name s_address s_phone supplier

n2 = 16
N2 = 26
