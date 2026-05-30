using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace LINQDemo;

class Q15
{

	public void runQuery(OdbcConnection connection)
	{
        var suppliers = connection.Query<Supplier>("SELECT s_suppkey, s_name, s_address, s_phone FROM samples.tpch.supplier").ToList();
        var lineitems = connection.Query<LineItem>("SELECT l_suppkey, l_extendedprice, l_discount, l_shipdate FROM samples.tpch.lineitem").ToList();

        var filtered = (from l in lineitems
                        where l.l_shipdate >= new DateTime(1996, 1, 1) && l.l_shipdate < new DateTime(1996, 4, 1)
                        group l by l.l_suppkey into g
                        select new
                        {
                            SupplierNo = g.Key,
                            TotalRevenue = g.Sum(item => item.l_extendedprice * (1 - item.l_discount))
                        } into revenueStream
                        group revenueStream by 1 into globalGroup
                        from r in globalGroup
                        let maxRevenue = globalGroup.Any() ? globalGroup.Max(x => x.TotalRevenue) : 0
                        where r.TotalRevenue == maxRevenue
                        join s in suppliers on r.SupplierNo equals s.s_suppkey
                        orderby s.s_suppkey
                        select new
                        {
                            s.s_suppkey,
                            s.s_name,
                            s.s_address,
                            s.s_phone,
                            r.TotalRevenue
                        }).ToList();

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

        // // Single continuous LINQ pipeline using Query Syntax
        // var filtered = (from l in lineitems
        //                 // |> WHERE l_shipdate >= ... AND l_shipdate < ...
        //                 where l.l_shipdate >= startDate && l.l_shipdate < endDate
                        
        //                 // |> AGGREGATE SUM(...) GROUP BY l_suppkey
        //                 group l by l.l_suppkey into g
                        
        //                 // |> SELECT l_suppkey AS supplier_no, total_revenue
        //                 select new
        //                 {
        //                     SupplierNo = g.Key,
        //                     TotalRevenue = g.Sum(item => item.l_extendedprice * (1 - item.l_discount))
        //                 } into revenueStream
                        
        //                 // |> EXTEND MAX(total_revenue) OVER() AS max_revenue
        //                 group revenueStream by 1 into globalGroup
        //                 from r in globalGroup
        //                 let maxRevenue = globalGroup.Any() ? globalGroup.Max(x => x.TotalRevenue) : 0
                        
        //                 // |> WHERE total_revenue = max_revenue
        //                 where r.TotalRevenue == maxRevenue
                        
        //                 // |> JOIN samples.tpch.supplier ON supplier_no = s_suppkey
        //                 join s in suppliers on r.SupplierNo equals s.s_suppkey
                        
        //                 // |> ORDER BY s_suppkey
        //                 orderby s.s_suppkey
                        
        //                 // |> SELECT s_suppkey, s_name, s_address, s_phone, total_revenue
        //                 select new
        //                 {
        //                     s.s_suppkey,
        //                     s.s_name,
        //                     s.s_address,
        //                     s.s_phone,
        //                     r.TotalRevenue
        //                 }).ToList();

        Utility.Print(filtered);
	}
}