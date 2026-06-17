from customer
select {customer_key = c_custkey, customer_segment_renamed = c_mktsegment}
filter customer_key > 100
group customer_segment_renamed (
	aggregate {
		customer_count = count customer_key
	}
)
sort {-customer_count}
