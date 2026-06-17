FROM customer
|> SELECT c_custkey AS customer_key, c_mktsegment AS customer_segment_renamed, c_nationkey
|> WHERE customer_key > 100
|> JOIN nation on c_nationkey = n_nationkey
|> AGGREGATE COUNT(customer_key) AS customer_count GROUP BY customer_segment_renamed, n_name
|> ORDER BY customer_count DESC;
