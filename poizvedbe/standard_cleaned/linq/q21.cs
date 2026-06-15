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
                .Take(100);


var = () from in join Where => . > on equals == where Any && != ! group by into orderby Count descending select new Take ;

n1 = 28
N1 = 93

filtered s suppliers l1 lineitems l l_receiptdate l_commitdate s_suppkey l_suppkey o orders o_orderstatus "F" l_orderkey o_orderkey n nations n_name "SAUDI ARABIA" s_nationkey n_nationkey l2 l3 s_name g Key numwait 100

n2 = 29
N2 = 68
