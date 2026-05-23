using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace LINQDemo;

class Q1
{

	public void runQuery(OdbcConnection connection)
	{
		string sql = "SELECT * FROM samples.tpch.lineitem WHERE l_shipdate <= CAST('1992-09-02' AS date)";
        var lineitem = connection.Query<LineItem>(sql).ToList();

		var filtered = from item in lineitem
					   where item.l_shipdate <= new DateTime(1992, 9, 2)
                       group item by new { item.l_returnflag, item.l_linestatus } into g
                       orderby g.Key.l_returnflag, g.Key.l_linestatus
                       select new
                       {
                           g.Key.l_returnflag,
                           g.Key.l_linestatus,
                           sum_qty         = g.Sum(x => x.l_quantity),
                           sum_base_price  = g.Sum(x => x.l_extendedprice),
                           sum_disc_price  = g.Sum(x => x.l_extendedprice * (1 - x.l_discount)),
                           sum_charge      = g.Sum(x => x.l_extendedprice * (1 - x.l_discount) * (1 + x.l_tax)),
                           avg_qty         = g.Average(x => x.l_quantity),
                           avg_price       = g.Average(x => x.l_extendedprice),
                           avg_disc        = g.Average(x => x.l_discount),
                           count_order     = g.Count()
                       };

        Utility.Print(filtered);
	}
}
