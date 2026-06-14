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
                });

var = new () , . ; from in on equals into let Count => == || ! IsMatch group by orderby descending select {} join

n1 = 26
N1 = 55

excludeRegex "special.*requests" RegexOptions Regex Compiled filtered c customers o orders c_custkey o_custkey custOrders orderCount o_comment null g Key c_count custdist 

n2 = 20
N2 = 34
