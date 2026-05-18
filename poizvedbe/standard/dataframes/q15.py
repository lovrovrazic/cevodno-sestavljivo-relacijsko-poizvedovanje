q15 = (
    lineitem_q15
    .loc[lambda d: (d["l_shipdate"] >= date(1996, 1, 1)) & (d["l_shipdate"] < date(1996, 4, 1))]
    .assign(revenue=lambda d: d["l_extendedprice"] * (1 - d["l_discount"]))
    .groupby("l_suppkey", as_index=False)["revenue"].sum()
    .rename(columns={"l_suppkey": "supplier_no", "revenue": "total_revenue"})
    .loc[lambda d: d["total_revenue"] == d["total_revenue"].max()]
    .merge(supplier, left_on="supplier_no", right_on="s_suppkey")[["s_suppkey", "s_name", "s_address", "s_phone", "total_revenue"]]
    .sort_values("s_suppkey")
)
print(q15)
