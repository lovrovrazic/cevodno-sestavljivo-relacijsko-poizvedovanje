_late = lineitem_q21.query("l_receiptdate > l_commitdate")
_n_suppliers = lineitem_q21.groupby("l_orderkey")["l_suppkey"].nunique()
_n_late_suppliers = _late.groupby("l_orderkey")["l_suppkey"].nunique()

q21_piped = (
    supplier
    .merge(nation.query("n_name == 'SAUDI ARABIA'")[["n_nationkey"]],
           left_on="s_nationkey", right_on="n_nationkey")
    .merge(_late, left_on="s_suppkey", right_on="l_suppkey")
    .merge(orders.query("o_orderstatus == 'F'")[["o_orderkey"]],
           left_on="l_orderkey", right_on="o_orderkey")
           
    .assign(n_suppliers=lambda d: d["l_orderkey"].map(_n_suppliers),
            n_late=lambda d: d["l_orderkey"].map(_n_late_suppliers))
    .query("n_suppliers > 1 and n_late == 1")
    .groupby("s_name", as_index=False).size().rename(columns={"size": "numwait"})
    .sort_values(["numwait", "s_name"], ascending=[False, True])
    .head(100)
)
print(q21_piped)


The two drop_duplicates calls only exist to undo row inflation from the EXISTS/NOT EXISTS semi/anti joins implemented via merge. You can avoid them entirely by pre-aggregating per l_orderkey and joining a scalar fact onto each l1 row instead of joining the full pair table.

The two correlated subqueries reduce to two facts per order:

EXISTS l2 with suppkey ≠ l1.suppkey ⇔ the order has >1 distinct supplier.
NOT EXISTS l3 late with suppkey ≠ l1.suppkey ⇔ only one distinct late supplier on the order (and since l1 is late, that one must be l1 itself).
So per order: n_suppliers > 1 and n_late_suppliers == 1. Each l1 row keeps its identity — no inflation, no dedup.

Applying it:

Same results (Supplier#000047969 = 23, etc.), no drop_duplicates, and execution should be faster since the two big merges against full lineitem pair tables are gone.

General pattern: when a merge is only there to express a semi/anti-join with a condition, reduce that condition to a per-key aggregate (nunique, any, min, max, set membership, count) and .map/.merge the scalar onto each row. Drop-duplicates is then unnecessary because rows never multiplied.