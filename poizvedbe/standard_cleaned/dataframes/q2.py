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

= () . merge , loc lambda : [] == & endswith assign groupby transform sort_values head

n1 = 17
N1 = 96

q2 part partsupp left_on "p_partkey" right_on "ps_partkey" supplier "ps_suppkey" "s_suppkey" nation "s_nationkey" "n_nationkey" region "n_regionkey" "r_regionkey" d "p_size" 15 "p_type" str "BRASS" "r_name" "EUROPE" min_cost_per_part "min" "s_acctbal" "s_name" "n_name" "p_mfgr" "s_address" "s_phone" "s_comment" ascending False True 100 

n2 = 37
N2 = 59
