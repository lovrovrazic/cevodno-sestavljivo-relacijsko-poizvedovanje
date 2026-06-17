WITH

customers AS (
  SELECT
    c_custkey AS customer_key,
    c_mktsegment AS customer_segment
  FROM
    customer
)

SELECT
  customer_segment,
  COUNT(customer_key) AS customer_count
FROM
  customers
WHERE
  customer_key > 100
GROUP BY
  customer_segment
ORDER BY
  customer_count DESC;
