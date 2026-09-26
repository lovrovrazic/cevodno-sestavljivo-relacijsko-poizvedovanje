using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace Jadralci;

class Q1
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
                       // |> WHERE c.barva = 'rdeca'
                       .Where(x => x.c.barva == "rdeca")
                       // |> SELECT
                       //      j.ime AS ime_jadralca,
                       //      c.ime AS ime_colna,
                       //      r.dan AS datum_rezervacije
                       .Select(x => new
                       {
                           ime_jadralca = x.j.ime,
                           ime_colna = x.c.ime,
                           datum_rezervacije = x.r.dan
                       })
                       // |> ORDER BY datum_rezervacije DESC
                       .OrderByDescending(s => s.datum_rezervacije);

        Utility.Print(filtered);
    }
}
