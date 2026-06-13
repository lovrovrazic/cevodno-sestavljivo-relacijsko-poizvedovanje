var filtered = from item in lineitem
			   where item.l_shipdate <= new DateTime(1998, 9, 2)
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


var = from in where . <= , () new DateTime group by into {} orderby select Sum x => * - + Average Count ;

n1 = 26
N1 = 118


filtered item lineitem l_shipdate 1998 9 2 l_returnflag l_linestatus g Key sum_qty l_quantity sum_base_price l_extendedprice sum_disc_price l_discount sum_charge l_tax avg_qty avg_price avg_disc count_order

n2 = 23
N2 = 52
