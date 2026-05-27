using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;
using System.Text.RegularExpressions;

namespace LINQDemo;

class Q13
{

	public void runQuery(OdbcConnection connection)
	{
        var customers = connection.Query<Customer>("SELECT c_custkey FROM samples.tpch.customer").ToList();
        var orders = connection.Query<Orders>("SELECT o_orderkey, o_custkey, o_comment FROM samples.tpch.orders").ToList();

        var excludeRegex = new Regex("special.*requests", RegexOptions.Compiled);

        var filtered = (from c in customers
                        join o in orders on c.c_custkey equals o.o_custkey into custOrders
                        let orderCount = custOrders.Count(o => o.o_comment == null || !excludeRegex.IsMatch(o.o_comment))
                        group orderCount by orderCount into g
                        orderby g.Count() descending, g.Key descending
                        select new
                        {
                            c_count = g.Key,
                            custdist = g.Count()
                        })
                        .ToList();

        Utility.Print(filtered);
	}
}
