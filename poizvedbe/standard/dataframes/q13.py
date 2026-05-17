filtered_orders = orders[~orders["o_comment"].str.contains(r"special.*requests", regex=True, na=False)]

c_counts = (
    customer[["c_custkey"]]
    .merge(filtered_orders[["o_orderkey", "o_custkey"]], left_on="c_custkey", right_on="o_custkey", how="left")
    .groupby("c_custkey")["o_orderkey"]
    .count()
    .rename("c_count")
    .reset_index()
)

q13 = (
    c_counts.groupby("c_count")
    .size()
    .rename("custdist")
    .reset_index()
    .sort_values(["custdist", "c_count"], ascending=[False, False])
    .reset_index(drop=True)
)

q13

# ------------------------------------------------------------------------

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
    .reset_index(drop=True)
)

print(q13)