using System;
using System.Data.Odbc;
using System.Linq;
using Dapper;

namespace DatabricksMacDemo;

class Program
{
    static void Main(string[] args)
    {
        // On Mac, point directly to the installed .dylib file
        string macOdbcDriverPath = "/Library/databricks/databricksodbc/lib/libdatabricksodbc.dylib";

        string connectionString = 
            $"Driver={macOdbcDriverPath};" +
             "Host=adb-xxxxxxxxxxxxxxxx.x.azuredatabricks.net;" + // Your Databricks workspace host
             "Port=443;" +
             "HTTPPath=sql/protocolv1/o/XXXXXXX/XXXXXXX;" +      // From connection details
             "ThriftTransport=2;" +
             "SSL=1;" +
             "AuthMech=3;" +
             "UID=token;" +
             $"PWD=dapiYourPersonalAccessTokenHere;" +
             "Catalog=samples;" +
             "ConnSchema=tchp;";

        Console.WriteLine("Connecting to Databricks from macOS...");

        try
        {
            using var connection = new OdbcConnection(connectionString);
            connection.Open();
            Console.WriteLine("Successfully connected!");

            // 1. Fetch data through the free driver using raw SQL
            string sql = "SELECT * FROM your_table_name LIMIT 100";
            var rawData = connection.Query<TchpData>(sql).ToList();

            // 2. Perform your clean LINQ queries locally in memory
            var filtered = from item in rawData
                           where item.MetricName.Contains("test", StringComparison.OrdinalIgnoreCase)
                           select item;

            foreach (var row in filtered)
            {
                Console.WriteLine($"ID: {row.Id} | Metric: {row.MetricName}");
            }
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Connection failed: {ex.Message}");
            Console.ResetColor();
        }
    }
}

// Simple data model mapping to your schema objects
public class TchpData
{
    public string Id { get; set; }
    public string MetricName { get; set; }
    public double Value { get; set; }
}
