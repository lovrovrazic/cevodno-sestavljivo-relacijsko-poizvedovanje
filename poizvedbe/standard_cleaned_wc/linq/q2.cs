var filtered = (from p in parts
                where p.p_size == 15 && p.p_type.EndsWith("BRASS")
                join ps in partsupps on p.p_partkey equals ps.ps_partkey
                join s in suppliers on ps.ps_suppkey equals s.s_suppkey
                join n in nations on s.s_nationkey equals n.n_nationkey
                join r in regions on n.n_regionkey equals r.r_regionkey
                where r.r_name == "EUROPE"
                group new { p, ps, s, n } by p.p_partkey into partGroup
                let minCost = partGroup.Min(x => x.ps.ps_supplycost)
                from row in partGroup
                where row.ps.ps_supplycost == minCost
                orderby row.s.s_acctbal descending, row.n.n_name, row.s.s_name, row.p.p_partkey
                select new
                {
                    row.s.s_acctbal,
                    row.s.s_name,
                    row.n.n_name,
                    row.p.p_partkey,
                    row.p.p_mfgr,
                    row.s.s_address,
                    row.s.s_phone,
                    row.s.s_comment
                })
                .Take(100);