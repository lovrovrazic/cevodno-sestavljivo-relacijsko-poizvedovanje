using System;
using System.Data.Odbc;
using System.Reflection;
using Microsoft.Extensions.Configuration;

namespace LINQDemo;

class Program
{
    static void Main(string[] args)
    {

    	var config = new ConfigurationBuilder()
            .AddUserSecrets(Assembly.GetExecutingAssembly())
            .Build();

		string host = config["Databricks:Host"];
        string httpPath = config["Databricks:HTTPPath"];
        string token = config["Databricks:Token"];
        string macOdbcDriverPath = "/Library/databricks/databricksodbc/lib/libdatabricksodbc.dylib";

        string connectionString = 
            $"Driver={macOdbcDriverPath};" +
            $"Host={host};" + 
            "Port=443;" +
            $"HTTPPath={httpPath};" +
            "ThriftTransport=2;" +
            "SSL=1;" +
            "AuthMech=3;" +
            "UID=token;" +
            $"PWD={token};" +
            "Catalog=samples;" +
            "ConnSchema=tchp;";

        Console.WriteLine("Connecting to Databricks from macOS...");

        try
        {
            using var connection = new OdbcConnection(connectionString);
            connection.Open();
            Console.WriteLine("Successfully connected!");

            // var q1 = new Q1();
            // Console.WriteLine("Starting Q1...");
            // q1.runQuery(connection);

            // var q2 = new Q2();
            // Console.WriteLine("Starting Q2...");
            // q2.runQuery(connection);

            // var q13 = new Q13();
            // Console.WriteLine("Starting Q13...");
            // q13.runQuery(connection);

            var q15 = new Q15();
            Console.WriteLine("Starting Q15...");
            q15.runQuery(connection);

        }
        catch (Exception ex)
        {
            Console.WriteLine($"Connection failed: {ex.Message}");
        }
    }
}
