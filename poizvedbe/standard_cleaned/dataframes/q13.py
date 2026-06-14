q13 = (
    customer
    .merge(
        orders[~orders["o_comment"].str.contains(r"special.*requests", regex=True, na=False)],
        left_on="c_custkey", right_on="o_custkey", how="left",
    )
    .groupby("c_custkey", as_index=False)
    .agg(c_count=("o_orderkey", "count"))
    .groupby("c_count", as_index=False)
    .agg(custdist=("c_count", "size"))
    .sort_values(["custdist", "c_count"], ascending=[False, False])
)

= () . merge [] ~ contains groupby , agg sort_values 

n1 = 11
N1 = 54

q13 customer orders "o_comment" str r"special.*requests" regex True na False left_on "c_custkey" right_on "o_custkey" how "left" as_index c_count "c_count" "o_orderkey" "count" custdist "custdist" "size" ascending 

n2 = 25
N2 = 34
