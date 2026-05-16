cutoff = pd.Timestamp("1998-12-01") - pd.Timedelta(days=90)

q1 = (
    lineitem
      .loc[pd.to_datetime(lineitem["l_shipdate"]) <= cutoff]
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
print(q1)
