from customer
select {customer_key = c_custkey, customer_segment_renamed = c_mktsegment, c_nationkey}
filter customer_key > 100
join nation (c_nationkey == n_nationkey)
group {customer_segment_renamed, n_name} (
	aggregate {
		customer_count = count customer_key
	}
)
sort {-customer_count}
