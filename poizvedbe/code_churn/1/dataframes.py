cc = (
  customer
  .loc[:, ["c_custkey", "c_mktsegment"]]
  .rename(columns={"c_custkey": "customer_key", "c_mktsegment": "customer_segment_renamed"})
  .query("customer_key > 100")
  .groupby("customer_segment_renamed", as_index=False)
  .agg(customer_count=("customer_key", "count"))
  .sort_values("customer_count", ascending=False)
)
