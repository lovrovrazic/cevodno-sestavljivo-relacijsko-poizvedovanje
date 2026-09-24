import numpy as np

second_dataframe = (
    # FROM Jadralec AS j
    jadralec.add_prefix("j.")
    # |> JOIN Rezervacija AS r ON j.jid = r.jid
    .merge(rezervacija.add_prefix("r."), how="inner", left_on="j.jid", right_on="r.jid")
    # |> JOIN Coln AS c ON r.cid = c.cid
    .merge(coln.add_prefix("c."), how="inner", left_on="r.cid", right_on="c.cid")
    # |> AGGREGATE COUNT(r.cid) AS stevilo_rezervacij, ROUND(AVG(c.dolzina), 1) AS povprecna_dolzina_colna
    #    GROUP BY j.jid, j.ime
    .groupby(["j.jid", "j.ime"], as_index=False)
    .agg(
        stevilo_rezervacij=("r.cid", "count"),
        povprecna_dolzina_colna=("c.dolzina", lambda s: np.floor(s.mean() * 10 + 0.5) / 10),
    )
    # |> WHERE stevilo_rezervacij > 1
    .loc[lambda df: df["stevilo_rezervacij"] > 1]
    # |> SELECT j.ime AS ime_jadralca, stevilo_rezervacij, povprecna_dolzina_colna
    .loc[:, ["j.ime", "stevilo_rezervacij", "povprecna_dolzina_colna"]]
    .rename(columns={"j.ime": "ime_jadralca"})
    # |> ORDER BY stevilo_rezervacij DESC
    .sort_values("stevilo_rezervacij", ascending=False)
    .reset_index(drop=True)
)

second_dataframe