q21 = (
  supplier
    .merge(
        lineitem_q21
            .query("l_receiptdate > l_commitdate")
            .rename(columns=lambda c: c.replace("l_", "l1_")),
        left_on="s_suppkey", right_on="l1_suppkey",
    )
    .merge(orders.query("o_orderstatus == 'F'")[["o_orderkey"]],
           left_on="l1_orderkey", right_on="o_orderkey")
    .merge(nation.query("n_name == 'SAUDI ARABIA'")[["n_nationkey"]],
           left_on="s_nationkey", right_on="n_nationkey")
    .merge(
        lineitem_q21[["l_orderkey", "l_suppkey"]]
            .drop_duplicates()
            .rename(columns={"l_orderkey": "l1_orderkey", "l_suppkey": "l2_suppkey"}),
        on="l1_orderkey",
    )
    .query("l2_suppkey != l1_suppkey")
    .drop_duplicates(subset=["s_name", "l1_orderkey", "l1_suppkey"])
    .drop(columns="l2_suppkey")
    .merge(
        lineitem_q21
            .query("l_receiptdate > l_commitdate")[["l_orderkey", "l_suppkey"]]
            .drop_duplicates()
            .rename(columns={"l_orderkey": "l1_orderkey", "l_suppkey": "l3_suppkey"}),
        on="l1_orderkey", how="left",
    )
    .assign(_bad=lambda d: d["l3_suppkey"].notna() & (d["l3_suppkey"] != d["l1_suppkey"]))
    .assign(_any_bad=lambda d: d.groupby(["l1_orderkey", "l1_suppkey"])["_bad"].transform("any"))
    .loc[lambda d: ~d["_any_bad"]]
    .drop_duplicates(subset=["s_name", "l1_orderkey", "l1_suppkey"])
    .groupby("s_name", as_index=False).size().rename(columns={"size": "numwait"})
    .sort_values(["numwait", "s_name"], ascending=[False, True])
    .head(100)
)
print(q21)
