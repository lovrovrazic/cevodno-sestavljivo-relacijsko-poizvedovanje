size_filter = 15
type_suffix = "BRASS"
region_filter = "EUROPE"

eur_nations = nation.merge(
    region.loc[region["r_name"] == region_filter, ["r_regionkey"]],
    left_on="n_regionkey", right_on="r_regionkey",
)[["n_nationkey", "n_name"]]

eur_suppliers = supplier.merge(eur_nations, left_on="s_nationkey", right_on="n_nationkey")

eur_ps = partsupp.merge(eur_suppliers[["s_suppkey"]], left_on="ps_suppkey", right_on="s_suppkey")

min_cost = (
    eur_ps.groupby("ps_partkey", as_index=False)["ps_supplycost"].min()
          .rename(columns={"ps_supplycost": "min_supplycost"})
)

candidate_parts = part.loc[
    (part["p_size"] == size_filter) & part["p_type"].str.endswith(type_suffix),
    ["p_partkey", "p_mfgr"],
]

q2 = (
    candidate_parts
      .merge(eur_ps, left_on="p_partkey", right_on="ps_partkey")
      .merge(min_cost, on="ps_partkey")
      .loc[lambda d: d["ps_supplycost"] == d["min_supplycost"]]
      .merge(eur_suppliers, on="s_suppkey")
      .loc[:, ["s_acctbal", "s_name", "n_name", "p_partkey", "p_mfgr", "s_address", "s_phone", "s_comment"]]
      .sort_values(
          ["s_acctbal", "n_name", "s_name", "p_partkey"],
          ascending=[False, True, True, True],
      )
      .head(100)
)
q2

# ------------------------------------------------------------------------

q2 = (
    part
      .merge(partsupp, left_on="p_partkey", right_on="ps_partkey")
      .merge(supplier, left_on="ps_suppkey", right_on="s_suppkey")
      .merge(nation, left_on="s_nationkey", right_on="n_nationkey")
      .merge(region, left_on="n_regionkey", right_on="r_regionkey")
      .loc[lambda d: (d["p_size"] == 15)
                     & d["p_type"].str.endswith("BRASS")
                     & (d["r_name"] == "EUROPE")]
      .assign(min_cost_per_part=lambda d: d.groupby("p_partkey")["ps_supplycost"].transform("min"))
      .loc[lambda d: d["ps_supplycost"] == d["min_cost_per_part"]]
      .loc[:, ["s_acctbal", "s_name", "n_name", "p_partkey", "p_mfgr", "s_address", "s_phone", "s_comment"]]
      .sort_values(["s_acctbal", "n_name", "s_name", "p_partkey"],
                   ascending=[False, True, True, True])
      .head(100)
)
print(q2)

# ------------------------------------------------------------------------

eur_ps = (
    partsupp
      .merge(supplier[["s_suppkey", "s_nationkey"]], left_on="ps_suppkey", right_on="s_suppkey")
      .merge(nation[["n_nationkey", "n_regionkey"]], left_on="s_nationkey", right_on="n_nationkey")
      .merge(region[["r_regionkey", "r_name"]], left_on="n_regionkey", right_on="r_regionkey")
      .loc[lambda d: d["r_name"] == "EUROPE", ["ps_partkey", "ps_suppkey", "ps_supplycost"]]
)

outer_rows = (
    part.loc[(part["p_size"] == 15) & part["p_type"].str.endswith("BRASS")]
        .merge(eur_ps, left_on="p_partkey", right_on="ps_partkey")
        .merge(supplier, left_on="ps_suppkey", right_on="s_suppkey")
        .merge(nation, left_on="s_nationkey", right_on="n_nationkey")
)

q2_corr = (
    outer_rows
      .loc[outer_rows.apply(
          lambda r: r["ps_supplycost"] == eur_ps.loc[
              eur_ps["ps_partkey"] == r["p_partkey"], "ps_supplycost"
          ].min(),
          axis=1,
      )]
      .loc[:, ["s_acctbal", "s_name", "n_name", "p_partkey", "p_mfgr", "s_address", "s_phone", "s_comment"]]
      .sort_values(["s_acctbal", "n_name", "s_name", "p_partkey"], ascending=[False, True, True, True])
      .head(100)
      .reset_index(drop=True)
)
print(q2_corr)