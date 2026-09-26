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
                       from j in jadralec
                       // |> JOIN uc_development.lovro.Rezervacija AS r ON j.jid = r.jid
                       join r in rezervacija on j.jid equals r.jid
                       // |> JOIN uc_development.lovro.Coln AS c ON r.cid = c.cid
                       join c in coln on r.cid equals c.cid
                       // |> WHERE c.barva = 'rdeca'
                       where c.barva == "rdeca"
                       // |> SELECT
                       //      j.ime AS ime_jadralca,
                       //      c.ime AS ime_colna,
                       //      r.dan AS datum_rezervacije
                       select new
                       {
                           ime_jadralca = j.ime,
                           ime_colna = c.ime,
                           datum_rezervacije = r.dan
                       } into s
                       // |> ORDER BY datum_rezervacije DESC
                       orderby s.datum_rezervacije descending
                       select s;

        Utility.Print(filtered);
	}
}
