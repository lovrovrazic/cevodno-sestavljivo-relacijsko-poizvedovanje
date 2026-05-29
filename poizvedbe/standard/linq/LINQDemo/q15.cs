using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace LINQDemo;

class Q15
{

	public void runQuery(OdbcConnection connection)
	{
        // Fetch required datasets
        var suppliers = connection.Query<Supplier>("SELECT s_suppkey, s_name, s_address, s_phone FROM samples.tpch.supplier").ToList();
        var lineitems = connection.Query<LineItem>("SELECT l_suppkey, l_extendedprice, l_discount, l_shipdate FROM samples.tpch.lineitem").ToList();

        // // 1. Mimic 'revenue0' view: Group lineitems by supplier and calculate total revenue
        // var revenue0 = (from l in lineitems
        //                 where l.l_shipdate >= new DateTime(1996, 1, 1) && l.l_shipdate < new DateTime(1996, 4, 1)
        //                 group l by l.l_suppkey into g
        //                 select new
        //                 {
        //                     SupplierNo = g.Key,
        //                     TotalRevenue = g.Sum(item => item.l_extendedprice * (1 - item.l_discount))
        //                 }).ToList();

        // var maxRevenue = revenue0.Count > 0 ? revenue0.Max(r => r.TotalRevenue) : 0;

        // // 3. Filter and join suppliers matching the max revenue
        // var filtered = (from s in suppliers
        //                 join r in revenue0 on s.s_suppkey equals r.SupplierNo
        //                 where r.TotalRevenue == maxRevenue
        //                 orderby s.s_suppkey
        //                 select new
        //                 {
        //                     s.s_suppkey,
        //                     s.s_name,
        //                     s.s_address,
        //                     s.s_phone,
        //                     r.TotalRevenue
        //                 }).ToList();

        var filtered = lineitems
            // |> WHERE l_shipdate >= ... AND l_shipdate < ...
            .Where(l => l.l_shipdate >= new DateTime(1996, 1, 1) && l.l_shipdate < new DateTime(1996, 4, 1))
            
            // |> AGGREGATE SUM(...) GROUP BY l_suppkey
            .GroupBy(l => l.l_suppkey)
            
            // |> SELECT l_suppkey AS supplier_no, total_revenue
            .Select(g => new 
            { 
                SupplierNo = g.Key, 
                TotalRevenue = g.Sum(item => item.l_extendedprice * (1 - item.l_discount)) 
            })
            
            // |> EXTEND MAX(total_revenue) OVER() AS max_revenue & WHERE total_revenue = max_revenue
            .GroupBy(r => 1) 
            .SelectMany(g => 
            {
                var maxRevenue = g.Any() ? g.Max(x => x.TotalRevenue) : 0;
                return g.Where(x => x.TotalRevenue == maxRevenue);
            })
            
            // |> JOIN samples.tpch.supplier ON supplier_no = s_suppkey
            // |> SELECT s_suppkey, s_name, s_address, s_phone, total_revenue
            .Join(suppliers, 
                  r => r.SupplierNo, 
                  s => s.s_suppkey, 
                  (r, s) => new 
                  {
                      s.s_suppkey,
                      s.s_name,
                      s.s_address,
                      s.s_phone,
                      r.TotalRevenue
                  })
            
            // |> ORDER BY s_suppkey;
            .OrderBy(result => result.s_suppkey)
            .ToList();

        Utility.Print(filtered);
	}
}