using System;

namespace LINQDemo;

// 1. LINEITEM
public class LineItem
{
    public long l_orderkey { get; set; }
    public long l_partkey { get; set; }
    public long l_suppkey { get; set; }
    public int l_linenumber { get; set; }
    public decimal l_quantity { get; set; }
    public decimal l_extendedprice { get; set; }
    public decimal l_discount { get; set; }
    public decimal l_tax { get; set; }
    public string l_returnflag { get; set; } = null!;
    public string l_linestatus { get; set; } = null!;
    public DateTime l_shipdate { get; set; }
    public DateTime l_commitdate { get; set; }
    public DateTime l_receiptdate { get; set; }
    public string l_shipinstruct { get; set; } = null!;
    public string l_shipmode { get; set; } = null!;
    public string l_comment { get; set; } = null!;
}

// 2. ORDERS
public class Orders
{
    public long o_orderkey { get; set; }
    public long o_custkey { get; set; }
    public string o_orderstatus { get; set; } = null!;
    public decimal o_totalprice { get; set; }
    public DateTime o_orderdate { get; set; }
    public string o_orderpriority { get; set; } = null!;
    public string o_clerk { get; set; } = null!;
    public int o_shippriority { get; set; }
    public string o_comment { get; set; } = null!;
}

// 3. CUSTOMER
public class Customer
{
    public long c_custkey { get; set; }
    public string c_name { get; set; } = null!;
    public string c_address { get; set; } = null!;
    public long c_nationkey { get; set; }
    public string c_phone { get; set; } = null!;
    public decimal c_acctbal { get; set; }
    public string c_mktsegment { get; set; } = null!;
    public string c_comment { get; set; } = null!;
}

// 4. PART
public class Part
{
    public long p_partkey { get; set; }
    public string p_name { get; set; } = null!;
    public string p_mfgr { get; set; } = null!;
    public string p_brand { get; set; } = null!;
    public string p_type { get; set; } = null!;
    public int p_size { get; set; }
    public string p_container { get; set; } = null!;
    public decimal p_retailprice { get; set; }
    public string p_comment { get; set; } = null!;
}

// 5. SUPPLIER
public class Supplier
{
    public long s_suppkey { get; set; }
    public string s_name { get; set; } = null!;
    public string s_address { get; set; } = null!;
    public long s_nationkey { get; set; }
    public string s_phone { get; set; } = null!;
    public decimal s_acctbal { get; set; }
    public string s_comment { get; set; } = null!;
}

// 6. PARTSUPP (Part Supplier Relationship Table)
public class PartSupp
{
    public long ps_partkey { get; set; }
    public long ps_suppkey { get; set; }
    public int ps_availqty { get; set; }
    public decimal ps_supplycost { get; set; }
    public string ps_comment { get; set; } = null!;
}

// 7. NATION
public class Nation
{
    public long n_nationkey { get; set; }
    public string n_name { get; set; } = null!;
    public long n_regionkey { get; set; }
    public string n_comment { get; set; } = null!;
}

// 8. REGION
public class Region
{
    public long r_regionkey { get; set; }
    public string r_name { get; set; } = null!;
    public string r_comment { get; set; } = null!;
}