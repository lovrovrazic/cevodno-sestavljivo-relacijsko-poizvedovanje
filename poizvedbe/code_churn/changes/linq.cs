var filtered =  from c in customers
                select new 
                { 
                    customer_key = c.c_custkey, 
                    customer_segment_renamed = c.c_mktsegment 
                } into c
                where c.customer_key > 100
                group c by c.customer_segment_renamed into cGroup
                orderby cGroup.Count() descending
                select new
                {
                    customer_segment_renamed = cGroup.Key,
                    customer_count = cGroup.Count()
                };
