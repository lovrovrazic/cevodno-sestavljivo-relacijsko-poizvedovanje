q13 = (
    customer
    .merge(
        orders[~orders["o_comment"].str.contains(r"special.*requests", regex=True, na=False)],
        left_on="c_custkey", right_on="o_custkey", how="left",
    )
    .groupby("c_custkey", as_index=False)
    .agg(c_count=("o_orderkey", "count"))
    .groupby("c_count", as_index=False)
    .agg(custdist=("c_count", "size"))
    .sort_values(["custdist", "c_count"], ascending=[False, False])
)