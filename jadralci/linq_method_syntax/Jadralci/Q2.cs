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
                       jadralec
                       // |> JOIN Rezervacija AS r ON j.jid = r.jid
                       .Join(rezervacija,
                             j => j.jid,
                             r => r.jid,
                             (j, r) => new { j, r })
                       // |> JOIN Coln AS c ON r.cid = c.cid
                       .Join(coln,
                             x => x.r.cid,
                             c => c.cid,
                             (x, c) => new { x.j, x.r, c })
                       // |> AGGREGATE
                       //      COUNT(r.cid) AS stevilo_rezervacij,
                       //      ROUND(AVG(c.dolzina), 1) AS povprecna_dolzina_colna
                       //    GROUP BY j.jid, j.ime
                       .GroupBy(x => new { x.j.jid, x.j.ime },
                                x => x.c)
                       .Select(g => new
                       {
                           g.Key.jid,
                           g.Key.ime,
                           stevilo_rezervacij = g.Count(),
                           povprecna_dolzina_colna = Math.Round(g.Average(c => c.dolzina), 1, MidpointRounding.AwayFromZero)
                       })
                       // |> WHERE stevilo_rezervacij > 1
                       .Where(a => a.stevilo_rezervacij > 1)
                       // |> SELECT
                       //      j.ime AS ime_jadralca,
                       //      stevilo_rezervacij,
                       //      povprecna_dolzina_colna
                       .Select(a => new
                       {
                           ime_jadralca = a.ime,
                           a.stevilo_rezervacij,
                           a.povprecna_dolzina_colna
                       })
                       // |> ORDER BY stevilo_rezervacij DESC
                       .OrderByDescending(s => s.stevilo_rezervacij);

        Utility.Print(filtered);
    }
}
