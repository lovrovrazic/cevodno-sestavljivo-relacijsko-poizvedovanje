using System;
using System.Collections.Generic;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace LINQDemo;

class Q2
{
    public void runQuery(OdbcConnection connection)
    {
        var parts = connection.Query<Part>("SELECT p_partkey, p_mfgr, p_type, p_size FROM samples.tpch.part").ToList();
        var suppliers = connection.Query<Supplier>("SELECT s_suppkey, s_name, s_address, s_nationkey, s_phone, s_acctbal, s_comment FROM samples.tpch.supplier").ToList();
        var partsupps = connection.Query<PartSupp>("SELECT ps_partkey, ps_suppkey, ps_supplycost FROM samples.tpch.partsupp").ToList();
        var nations = connection.Query<Nation>("SELECT n_nationkey, n_name, n_regionkey FROM samples.tpch.nation").ToList();
        var regions = connection.Query<Region>("SELECT r_regionkey, r_name FROM samples.tpch.region").ToList();

        int targetSize = 15;
        string targetType = "BRASS";
        string targetRegion = "EUROPE";

        // Translate the Correlated Subquery: Find the minimum supply cost per part in the target region
        var minCosts = (from ps in partsupps
                        join s in suppliers on ps.ps_suppkey equals s.s_suppkey
                        join n in nations on s.s_nationkey equals n.n_nationkey
                        join r in regions on n.n_regionkey equals r.r_regionkey
                        where r.r_name == targetRegion
                        group ps.ps_supplycost by ps.ps_partkey into g
                        select new { PartKey = g.Key, MinCost = g.Min() })
                       .ToDictionary(x => x.PartKey, x => x.MinCost);

        // Main Query execution matching the outer SQL logic
        var filtered = (from p in parts
                        where p.p_size == targetSize && p.p_type.EndsWith(targetType) // LIKE '%[TYPE]'
                        join ps in partsupps on p.p_partkey equals ps.ps_partkey
                        join s in suppliers on ps.ps_suppkey equals s.s_suppkey
                        join n in nations on s.s_nationkey equals n.n_nationkey
                        join r in regions on n.n_regionkey equals r.r_regionkey
                        where r.r_name == targetRegion 
                           && minCosts.TryGetValue(p.p_partkey, out var minCost) 
                           && ps.ps_supplycost == minCost
                        orderby s.s_acctbal descending, n.n_name, s.s_name, p.p_partkey
                        select new
                        {
                            s.s_acctbal,
                            s.s_name,
                            n.n_name,
                            p.p_partkey,
                            p.p_mfgr,
                            s.s_address,
                            s.s_phone,
                            s.s_comment
                        })
                        .Take(100) // LIMIT 100
                        .ToList();

        Utility.Print(filtered);
    }
}
