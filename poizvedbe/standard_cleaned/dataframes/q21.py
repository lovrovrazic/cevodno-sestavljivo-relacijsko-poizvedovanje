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


= . query groupby nunique () merge [] , assign lambda : map size rename sort_values head

n1 = 17
N1 = 99

_late lineitem_q21 "l_receiptdate > l_commitdate" _n_suppliers "l_orderkey" "l_suppkey" _n_late_suppliers q21_piped supplier nation "n_name == 'SAUDI ARABIA'" "n_nationkey" left_on "s_nationkey" right_on "s_suppkey" orders "o_orderstatus == 'F'" "o_orderkey" n_suppliers d n_late "n_suppliers > 1 and n_late == 1" "s_name" as_index False columns "size" "numwait" ascending True 100 size

n2 = 33
N2 = 56
