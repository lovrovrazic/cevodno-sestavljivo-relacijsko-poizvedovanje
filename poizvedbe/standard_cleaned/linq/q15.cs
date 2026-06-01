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