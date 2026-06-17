cc = (
  customer
  .loc[:, ["c_custkey", "c_mktsegment", "c_nationkey"]]
  .rename(columns={"c_custkey": "customer_key", "c_mktsegment": "customer_segment_renamed"})
  .query("customer_key > 100")
  .merge(nation.loc[:, ["n_nationkey", "n_name"]], left_on="c_nationkey", right_on="n_nationkey", how="inner")
  .groupby(["customer_segment_renamed", "n_name"], as_index=False)
  .agg(customer_count=("customer_key", "count"))
  .sort_values("customer_count", ascending=False)
)
