q1 = (
    lineitem
    .loc[pd.to_datetime(lineitem["l_shipdate"]) <= pd.Timestamp("1998-09-02")]
    .assign(
        disc_price=lambda d: d["l_extendedprice"] * (1 - d["l_discount"]),
        charge=lambda d: d["l_extendedprice"] * (1 - d["l_discount"]) * (1 + d["l_tax"]),
    )
    .groupby(["l_returnflag", "l_linestatus"], as_index=False)
    .agg(
        sum_qty=("l_quantity", "sum"),
        sum_base_price=("l_extendedprice", "sum"),
        sum_disc_price=("disc_price", "sum"),
        sum_charge=("charge", "sum"),
        avg_qty=("l_quantity", "mean"),
        avg_price=("l_extendedprice", "mean"),
        avg_disc=("l_discount", "mean"),
        count_order=("l_quantity", "size"),
    )
    .sort_values(["l_returnflag", "l_linestatus"])
)

= () . loc [] to_datetime <= Timestamp assign lambda : * - + , groupby agg sort_values

n1 = 18
N1 = 87

q1 lineitem pd "l_shipdate" "1998-09-02" disc_price d "l_extendedprice" 1 "l_discount" charge "l_tax" "l_returnflag" "l_linestatus" as_index False sum_qty "l_quantity" "sum" sum_base_price sum_disc_price "disc_price" sum_charge "charge" avg_qty "mean" avg_price avg_disc count_order "size"

n2 = 30
N1 = 53
