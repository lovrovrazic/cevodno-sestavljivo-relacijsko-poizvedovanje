using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace LINQDemo;

class Q21
{

	public void runQuery(OdbcConnection connection)
	{
        var suppliers = connection.Query<Supplier>("SELECT s_suppkey, s_name, s_address, s_phone, s_nationkey FROM samples.tpch.supplier").ToList();
        var lineitems = connection.Query<Lineitem>("SELECT l_orderkey, l_suppkey, l_receiptdate, l_commitdate FROM samples.tpch.lineitem").ToList();
        var orders = connection.Query<Order>("SELECT o_orderkey, o_orderstatus FROM samples.tpch.orders").ToList();
        var nations = connection.Query<Nation>("SELECT n_nationkey, n_name FROM samples.tpch.nation").ToList();

        var filtered = (from s in suppliers
                        join l1 in lineitems on s.s_suppkey equals l1.l_suppkey
                        join o in orders on l1.l_orderkey equals o.o_orderkey
                        join n in nations on s.s_nationkey equals n.n_nationkey
                        where o.o_orderstatus == "F"
                           && l1.l_receiptdate > l1.l_commitdate
                           && n.n_name == "SAUDI ARABIA" // Standard TPC-H Q21 default nation
                           // EXISTS: There is another supplier for the same order
                           && lineitems.Any(l2 => l2.l_orderkey == l1.l_orderkey && l2.l_suppkey != l1.l_suppkey)
                           // NOT EXISTS: No other supplier for the same order was late
                           && !lineitems.Any(l3 => l3.l_orderkey == l1.l_orderkey && l3.l_suppkey != l1.l_suppkey && l3.l_receiptdate > l3.l_commitdate)
                        group s by s.s_name into g
                        orderby g.Count() descending, g.Key
                        select new 
                        { 
                            s_name = g.Key, 
                            numwait = g.Count() 
                        })
                        .Take(10)
                        .ToList();


        Utility.Print(filtered);
	}
}
