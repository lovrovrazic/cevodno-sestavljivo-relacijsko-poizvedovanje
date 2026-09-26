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

        var filtered = // FROM uc_development.lovro.Jadralec AS j
                       jadralec
                       // |> JOIN uc_development.lovro.Rezervacija AS r ON j.jid = r.jid
                       .Join(rezervacija,
                             j => j.jid,
                             r => r.jid,
                             (j, r) => new { j, r })
                       // |> JOIN uc_development.lovro.Coln AS c ON r.cid = c.cid
                       .Join(coln,
                             x => x.r.cid,
                             c => c.cid,
                             (x, c) => new { x.j, x.r, c })
                       // |> AGGREGATE
                       //      COUNT(r.cid) AS stevilo_rezervacij,
                       //      COUNT(DISTINCT c.barva) AS rezervacije_unikatnih_barv,
                       //      MAX(c.dolzina) AS najvecja_dolzina_colna,
                       //      STRING_AGG(DISTINCT c.ime, ', ') AS znamke_colnov
                       //    GROUP BY j.jid, j.ime, j.rating
                       .GroupBy(x => new { x.j.jid, x.j.ime, x.j.rating },
                                x => x.c)
                       .Select(g => new
                       {
                           g.Key.jid,
                           g.Key.ime,
                           g.Key.rating,
                           stevilo_rezervacij = g.Count(),
                           rezervacije_unikatnih_barv = g.Select(c => c.barva).Distinct().Count(),
                           najvecja_dolzina_colna = g.Max(c => c.dolzina),
                           znamke_colnov = string.Join(", ", g.Select(c => c.ime).Distinct())
                       })
                       // |> SELECT
                       //      j.ime AS ime_jadralca,
                       //      j.rating,
                       //      stevilo_rezervacij,
                       //      rezervacije_unikatnih_barv,
                       //      najvecja_dolzina_colna,
                       //      znamke_colnov
                       .Select(a => new
                       {
                           ime_jadralca = a.ime,
                           a.rating,
                           a.stevilo_rezervacij,
                           a.rezervacije_unikatnih_barv,
                           a.najvecja_dolzina_colna,
                           a.znamke_colnov
                       })
                       // |> WHERE rezervacije_unikatnih_barv >= 2
                       .Where(s => s.rezervacije_unikatnih_barv >= 2)
                       // |> EXTEND RANK() OVER (ORDER BY stevilo_rezervacij DESC, rating DESC) AS stopnja_aktivnosti
                       .GroupBy(s => 1)
                       .SelectMany(vsi => vsi.Select(x => new
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
                       }))
                       // |> ORDER BY stopnja_aktivnosti
                       .OrderBy(e => e.stopnja_aktivnosti);

        Utility.Print(filtered);
    }
}
