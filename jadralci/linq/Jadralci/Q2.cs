using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace Jadralci;

class Q2
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
                       // |> AGGREGATE
                       //      COUNT(r.cid) AS stevilo_rezervacij,
                       //      ROUND(AVG(c.dolzina), 1) AS povprecna_dolzina_colna
                       //    GROUP BY j.jid, j.ime
                       group c by new { j.jid, j.ime } into g
                       select new
                       {
                           g.Key.jid,
                           g.Key.ime,
                           stevilo_rezervacij = g.Count(),
                           povprecna_dolzina_colna = Math.Round(g.Average(x => x.dolzina), 1, MidpointRounding.AwayFromZero)
                       } into a
                       // |> WHERE stevilo_rezervacij > 1
                       where a.stevilo_rezervacij > 1
                       // |> SELECT
                       //      j.ime AS ime_jadralca,
                       //      stevilo_rezervacij,
                       //      povprecna_dolzina_colna
                       select new
                       {
                           ime_jadralca = a.ime,
                           a.stevilo_rezervacij,
                           a.povprecna_dolzina_colna
                       } into s
                       // |> ORDER BY stevilo_rezervacij DESC
                       orderby s.stevilo_rezervacij descending
                       select s;

        Utility.Print(filtered);
	}
}
