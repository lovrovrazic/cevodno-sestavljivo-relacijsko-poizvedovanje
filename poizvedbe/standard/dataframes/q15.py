from datetime import date

revenue = (
    lineitem_q15
    .loc[
        (lineitem_q15["l_shipdate"] >= date(1996, 1, 1))
        & (lineitem_q15["l_shipdate"] < date(1996, 4, 1))
    ]
    .assign(revenue=lambda d: d["l_extendedprice"] * (1 - d["l_discount"]))
    .groupby("l_suppkey", as_index=False)["revenue"].sum()
    .rename(columns={"l_suppkey": "supplier_no", "revenue": "total_revenue"})
)

top = revenue.loc[revenue["total_revenue"] == revenue["total_revenue"].max()]

q15 = (
    supplier.merge(top, left_on="s_suppkey", right_on="supplier_no")
    [["s_suppkey", "s_name", "s_address", "s_phone", "total_revenue"]]
    .sort_values("s_suppkey")
    .reset_index(drop=True)
)
print(q15)

# ------------------------------------------------------------------------

poprav datum v zgornjega in brisis zgornje

cutoff_bottom = pd.Timestamp("1996-01-01")
cutoff_top = pd.Timestamp("1996-04-01")

q15 = (
    lineitem_q15
    .assign(l_shipdate=lambda d: pd.to_datetime(d["l_shipdate"]))
    .loc[lambda d: (d["l_shipdate"] >= cutoff_bottom) & (d["l_shipdate"] < cutoff_top)]
    .assign(revenue=lambda d: d["l_extendedprice"] * (1 - d["l_discount"]))
    .groupby("l_suppkey", as_index=False)["revenue"].sum()
    .rename(columns={"l_suppkey": "supplier_no", "revenue": "total_revenue"})
    .loc[lambda d: d["total_revenue"] == d["total_revenue"].max()]
    .merge(supplier, left_on="supplier_no", right_on="s_suppkey")
    [["s_suppkey", "s_name", "s_address", "s_phone", "total_revenue"]]
    .sort_values("s_suppkey")
    .reset_index(drop=True)
)
q15