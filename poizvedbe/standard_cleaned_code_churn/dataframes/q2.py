q2 = (
    part
    .merge(partsupp, left_on="p_partkey", right_on="ps_partkey")
    .merge(supplier, left_on="ps_suppkey", right_on="s_suppkey")
    .merge(nation, left_on="s_nationkey", right_on="n_nationkey")
    .merge(region, left_on="n_regionkey", right_on="r_regionkey")
    .loc[lambda d: (d["p_size"] == 15) & d["p_type"].str.endswith("BRASS") & (d["r_name"] == "EUROPE")]
    .assign(min_cost_per_part=lambda d: d.groupby("p_partkey")["ps_supplycost"].transform("min"))
    .loc[lambda d: d["ps_supplycost"] == d["min_cost_per_part"]]
    .loc[:, ["s_acctbal", "s_name", "n_name", "p_partkey", "p_mfgr", "s_address", "s_phone", "s_comment"]]
    .sort_values(["s_acctbal", "n_name", "s_name", "p_partkey"], ascending=[False, True, True, True])
    .head(100)
)