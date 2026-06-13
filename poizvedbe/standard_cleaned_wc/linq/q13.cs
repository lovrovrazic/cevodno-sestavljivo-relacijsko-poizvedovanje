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