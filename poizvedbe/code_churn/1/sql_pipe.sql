FROM samples.tpch.customer
|> SELECT c_custkey AS customer_key, c_mktsegment AS customer_segment_renamed
|> WHERE customer_key > 100
|> AGGREGATE COUNT(customer_key) AS customer_count GROUP BY customer_segment_renamed
|> ORDER BY customer_count DESC;
