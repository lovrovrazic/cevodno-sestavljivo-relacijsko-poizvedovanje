var filtered = (from s in suppliers
                join l1 in lineitems.Where(l => l.l_receiptdate > l.l_commitdate) on s.s_suppkey equals l1.l_suppkey
                join o in orders.Where(o => o.o_orderstatus == "F") on l1.l_orderkey equals o.o_orderkey
                join n in nations.Where(n => n.n_name == "SAUDI ARABIA") on s.s_nationkey equals n.n_nationkey
                where lineitems.Any(l2 => l2.l_orderkey == l1.l_orderkey && l2.l_suppkey != l1.l_suppkey)
                   && !lineitems.Any(l3 => l3.l_orderkey == l1.l_orderkey && l3.l_suppkey != l1.l_suppkey && l3.l_receiptdate > l3.l_commitdate)
                group s by s.s_name into g
                orderby g.Count() descending, g.Key
                select new 
                { 
                    s_name = g.Key, 
                    numwait = g.Count() 
                })
                .Take(100)
                .ToList();