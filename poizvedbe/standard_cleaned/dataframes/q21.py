_late = lineitem_q21.query("l_receiptdate > l_commitdate")
_n_suppliers = lineitem_q21.groupby("l_orderkey")["l_suppkey"].nunique()
_n_late_suppliers = _late.groupby("l_orderkey")["l_suppkey"].nunique()

q21_piped = (
    supplier
    .merge(nation.query("n_name == 'SAUDI ARABIA'")[["n_nationkey"]], left_on="s_nationkey", right_on="n_nationkey")
    .merge(_late, left_on="s_suppkey", right_on="l_suppkey")
    .merge(orders.query("o_orderstatus == 'F'")[["o_orderkey"]], left_on="l_orderkey", right_on="o_orderkey")
    .assign(n_suppliers=lambda d: d["l_orderkey"].map(_n_suppliers), n_late=lambda d: d["l_orderkey"].map(_n_late_suppliers))
    .query("n_suppliers > 1 and n_late == 1")
    .groupby("s_name", as_index=False).size().rename(columns={"size": "numwait"})
    .sort_values(["numwait", "s_name"], ascending=[False, True])
    .head(100)
)