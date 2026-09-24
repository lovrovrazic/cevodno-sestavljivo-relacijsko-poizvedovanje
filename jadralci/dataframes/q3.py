third_dataframe = (
    # FROM Jadralec AS j
    jadralec.add_prefix("j.")
    # |> JOIN Rezervacija AS r ON j.jid = r.jid
    .merge(rezervacija.add_prefix("r."), how="inner", left_on="j.jid", right_on="r.jid")
    # |> JOIN Coln AS c ON r.cid = c.cid
    .merge(coln.add_prefix("c."), how="inner", left_on="r.cid", right_on="c.cid")
    # |> AGGREGATE COUNT(r.cid) AS stevilo_rezervacij, COUNT(DISTINCT c.barva) AS rezervacije_unikatnih_barv,
    #              MAX(c.dolzina) AS najvecja_dolzina_colna, STRING_AGG(DISTINCT c.ime, ', ') AS znamke_colnov
    #    GROUP BY j.jid, j.ime, j.rating
    .groupby(["j.jid", "j.ime", "j.rating"], as_index=False)
    .agg(
        stevilo_rezervacij=("r.cid", "count"),
        rezervacije_unikatnih_barv=("c.barva", "nunique"),
        najvecja_dolzina_colna=("c.dolzina", "max"),
        znamke_colnov=("c.ime", lambda s: ", ".join(s.dropna().unique())),
    )
    # |> SELECT j.ime AS ime_jadralca, j.rating, stevilo_rezervacij, rezervacije_unikatnih_barv,
    #           najvecja_dolzina_colna, znamke_colnov
    .loc[:, ["j.ime", "j.rating", "stevilo_rezervacij", "rezervacije_unikatnih_barv",
             "najvecja_dolzina_colna", "znamke_colnov"]]
    .rename(columns={"j.ime": "ime_jadralca", "j.rating": "rating"})
    # |> WHERE rezervacije_unikatnih_barv >= 2
    .loc[lambda df: df["rezervacije_unikatnih_barv"] >= 2]
    # |> EXTEND RANK() OVER (ORDER BY stevilo_rezervacij DESC, rating DESC) AS stopnja_aktivnosti
    .sort_values(["stevilo_rezervacij", "rating"], ascending=[False, False])
    .assign(stopnja_aktivnosti=lambda df: (
        df.assign(_pos=range(1, len(df) + 1))
        .groupby(["stevilo_rezervacij", "rating"], dropna=False)["_pos"]
        .transform("min")
    ))
    # |> ORDER BY stopnja_aktivnosti
    .sort_values("stopnja_aktivnosti")
    .reset_index(drop=True)
)

third_dataframe