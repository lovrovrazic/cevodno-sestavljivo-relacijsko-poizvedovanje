first_dataframe = (
    # FROM uc_development.lovro.Jadralec AS j
    jadralec.add_prefix("j.")
    # |> JOIN uc_development.lovro.Rezervacija AS r ON j.jid = r.jid
    .merge(rezervacija.add_prefix("r."), how="inner", left_on="j.jid", right_on="r.jid")
    # |> JOIN uc_development.lovro.Coln AS c ON r.cid = c.cid
    .merge(coln.add_prefix("c."), how="inner", left_on="r.cid", right_on="c.cid")
    # |> WHERE c.barva = 'rdeca'
    .loc[lambda df: df["c.barva"] == "rdeca"]
    # |> SELECT j.ime AS ime_jadralca, c.ime AS ime_colna, r.dan AS datum_rezervacije
    .loc[:, ["j.ime", "c.ime", "r.dan"]]
    .rename(columns={"j.ime": "ime_jadralca", "c.ime": "ime_colna", "r.dan": "datum_rezervacije"})
    # |> ORDER BY datum_rezervacije DESC
    .sort_values("datum_rezervacije", ascending=False)
    .reset_index(drop=True)
)
first_dataframe