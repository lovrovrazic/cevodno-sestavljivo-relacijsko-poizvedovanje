import sqlglot
from sqlglot import exp

def analyze_sql_fully(sql_string):
    try:
        expression = sqlglot.parse_one(sql_string)
    except Exception as e:
        return f"Error parsing SQL: {e}"

    operators = []
    operands = []

    # Seznam vozlišč, ki smo jih že ročno obdelali (da preprečimo dvojno štetje)
    processed_nodes = set()

    for node in expression.walk():
        if id(node) in processed_nodes:
            continue

        # ----------------------------------------------------
        # 1. VEJICE (Ulovimo sezname npr. v SELECT ali GROUP BY)
        # ----------------------------------------------------
        # Če ima vozlišče več izrazov (npr. SELECT a, b, c), dodamo vejice
        if hasattr(node, "expressions") and isinstance(node.expressions, list):
            if len(node.expressions) > 1:
                # Število vejic je vedno število elementov - 1
                for _ in range(len(node.expressions) - 1):
                    operators.append(",")

        # ----------------------------------------------------
        # 2. ALIASI (AS) - npr. lineitem AS l1
        # ----------------------------------------------------
        if isinstance(node, exp.Alias):
            operators.append("AS")
            
            # Obdelava levega dela aliasa (npr. lineitem ali l1.price)
            left_part = node.this
            if isinstance(left_part, exp.Column) and left_part.table:
                operators.append(".")
                operands.append(left_part.table)
                operands.append(left_part.this.sql())
            else:
                operands.append(left_part.this.sql())
                
            # Obdelava desnega dela (alias ime, npr. l1)
            alias_part = node.args.get("alias")
            if alias_part:
                operands.append(alias_part.sql())
            
            # Označimo otroke kot obdelane, da jih walk() ne obišče ponovno
            for child in node.walk():
                processed_nodes.add(id(child))
            continue

        # ----------------------------------------------------
        # 3. STOLPCI IN TABELE S PIKO (.) - npr. l1.price ali db.table
        # ----------------------------------------------------
        elif isinstance(node, exp.Column):
            if node.table:
                operators.append(".")
                operands.append(node.table)
                operands.append(node.this.sql())
            else:
                operands.append(node.sql())
            processed_nodes.add(id(node))
            continue
            
        elif isinstance(node, exp.Table):
            if node.db:
                operators.append(".")
                operands.append(node.db)
                operands.append(node.this.sql())
            else:
                operands.append(node.sql())
            processed_nodes.add(id(node))
            continue

        # ----------------------------------------------------
        # 4. OSTALI STANDARDNI OPERATORJI
        # ----------------------------------------------------
        elif isinstance(node, (exp.Binary, exp.Unary)):
            operators.append(node.key.upper())
        elif isinstance(node, (exp.And, exp.Or)):
            operators.append(node.key.upper())
        elif isinstance(node, exp.Paren):
            operators.append("(")  # Desni oklepaj ) se lahko doda po želji, če zahteva sintaksa metriker

        # Strukturni SQL operatorji
        elif isinstance(node, exp.Select):
            operators.append("SELECT")
        elif isinstance(node, exp.Where):
            operators.append("WHERE")
        elif isinstance(node, exp.Join):
            operators.append(f"JOIN ({node.args.get('method', 'INNER').upper()})")
        elif isinstance(node, exp.Group):
            operators.append("GROUP BY")
        elif isinstance(node, exp.Order):
            operators.append("ORDER BY")

        # ----------------------------------------------------
        # 5. LITERALE IN ZVEZDICE
        # ----------------------------------------------------
        elif isinstance(node, exp.Literal):
            operands.append(node.sql())
        elif isinstance(node, exp.Star):
            operands.append("*")

    return {
        "total_operators": len(operators),
        "total_operands": len(operands),
        "operator_breakdown": operators,
        "operand_breakdown": operands
    }

# --- Testni primer, ki združuje vse vaše zahteve ---
sql_query = """
SELECT
    s_name,
    count(*) AS numwait
FROM
    supplier,
    lineitem l1,
    orders,
    nation
WHERE
    s_suppkey = l1.l_suppkey
    AND o_orderkey = l1.l_orderkey
    AND o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND EXISTS (
        SELECT
            *
        FROM
            lineitem l2
        WHERE
            l2.l_orderkey = l1.l_orderkey
            AND l2.l_suppkey <> l1.l_suppkey)
    AND NOT EXISTS (
        SELECT
            *
        FROM
            lineitem l3
        WHERE
            l3.l_orderkey = l1.l_orderkey
            AND l3.l_suppkey <> l1.l_suppkey
            AND l3.l_receiptdate > l3.l_commitdate)
    AND s_nationkey = n_nationkey
    AND n_name = 'SAUDI ARABIA'
GROUP BY
    s_name
ORDER BY
    numwait DESC,
    s_name
LIMIT 100;
"""
results = analyze_sql_fully(sql_query)

print(f"Skupno število operatorjev: {results['total_operators']}")
print(f"Operatorji: {results['operator_breakdown']}\n")
print(f"Skupno število operandov:  {results['total_operands']}")
print(f"Operandi:  {results['operand_breakdown']}")
