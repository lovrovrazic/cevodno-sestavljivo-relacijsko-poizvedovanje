using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace Jadralci;

class Q3
{

	public void runQuery(OdbcConnection connection)
	{
        var jadralec = connection.Query<Jadralec>("SELECT * FROM uc_development.lovro.jadralec").ToList();
        var coln = connection.Query<Coln>("SELECT * FROM uc_development.lovro.coln").ToList();
        var rezervacija = connection.Query<Rezervacija>("SELECT * FROM uc_development.lovro.rezervacija").ToList();

		var filtered = // FROM Jadralec AS j
                       from j in jadralec
                       // |> JOIN Rezervacija AS r ON j.jid = r.jid
                       join r in rezervacija on j.jid equals r.jid
                       // |> JOIN Coln AS c ON r.cid = c.cid
                       join c in coln on r.cid equals c.cid
                       // |> AGGREGATE ... GROUP BY j.jid, j.ime, j.rating
                       group c by new { j.jid, j.ime, j.rating } into g
                       select new
                       {
                           g.Key.jid,
                           g.Key.ime,
                           g.Key.rating,
                           stevilo_rezervacij = g.Count(),
                           rezervacije_unikatnih_barv = g.Select(x => x.barva).Distinct().Count(),
                           najvecja_dolzina_colna = g.Max(x => x.dolzina),
                           znamke_colnov = string.Join(", ", g.Select(x => x.ime).Distinct())
                       } into a
                       // |> SELECT ...
                       select new
                       {
                           ime_jadralca = a.ime,
                           a.rating,
                           a.stevilo_rezervacij,
                           a.rezervacije_unikatnih_barv,
                           a.najvecja_dolzina_colna,
                           a.znamke_colnov
                       } into s
                       // |> WHERE rezervacije_unikatnih_barv >= 2
                       where s.rezervacije_unikatnih_barv >= 2
                       // |> EXTEND RANK() OVER (ORDER BY stevilo_rezervacij DESC, rating DESC) AS stopnja_aktivnosti
                       group s by 1 into vsi
                       from x in vsi
                       select new
                       {
                           x.ime_jadralca,
                           x.rating,
                           x.stevilo_rezervacij,
                           x.rezervacije_unikatnih_barv,
                           x.najvecja_dolzina_colna,
                           x.znamke_colnov,
                           stopnja_aktivnosti = 1 + vsi.Count(o =>
                               o.stevilo_rezervacij > x.stevilo_rezervacij ||
                               (o.stevilo_rezervacij == x.stevilo_rezervacij && o.rating > x.rating))
                       } into e
                       // |> ORDER BY stopnja_aktivnosti
                       orderby e.stopnja_aktivnosti
                       select e;

        Utility.Print(filtered);
	}
}
