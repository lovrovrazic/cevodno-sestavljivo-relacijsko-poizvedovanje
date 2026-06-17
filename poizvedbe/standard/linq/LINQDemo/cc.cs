using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace LINQDemo;

class CC
{
    public void runQuery(OdbcConnection connection)
    {
        var customers = connection.Query<Customer>("SELECT c_custkey, c_mktsegment, c_nationkey FROM samples.tpch.customer").ToList();
        var nations = connection.Query<Nation>("SELECT n_name, n_nationkey FROM samples.tpch.nation").ToList();

        var filtered =  from c in customers
                        select new 
                        { 
                            customer_key = c.c_custkey, 
                            customer_segment_renamed = c.c_mktsegment,
                            c.c_nationkey 
                        } into c
                        where c.customer_key > 100
                        join n in nations on c.c_nationkey equals n.n_nationkey
                        group c by new 
                        { 
                            c.customer_segment_renamed, 
                            n.n_name 
                        } into cGroup
                        orderby cGroup.Count() descending
                        select new
                        {
                            customer_segment_renamed = cGroup.Key.customer_segment_renamed,
                            n_name = cGroup.Key.n_name,
                            customer_count = cGroup.Count()
                        };

        Utility.Print(filtered);
    }
}