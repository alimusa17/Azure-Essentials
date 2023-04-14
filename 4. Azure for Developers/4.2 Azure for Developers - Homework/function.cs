#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Data.SqlClient;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string name = req.Query["name"];

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    name = name ?? data?.name;

    if (name != null) 
    {
        // SQL Server DB connection string
        var str = "Server=tcp:su5afdsqlserv.database.windows.net,1433;Initial Catalog=su5afd-db;Persist Security Info=False;User ID=********;Password=*********************;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

        using (SqlConnection conn = new SqlConnection(str))
        {
            conn.Open();

            // Insert statement
            var text = "INSERT INTO Person (name) VALUES (@n)";

            using (SqlCommand cmd = new SqlCommand(text, conn))
            {
                cmd.Parameters.AddWithValue("@n", name);

                Int32 rowsAffected = cmd.ExecuteNonQuery();
                log.LogInformation("{0} row inserted", rowsAffected);

                // Select statement
                text = "SELECT name, min(data_time) as min_date, count(*) as cnt FROM Person WHERE name= @n group by name";
                cmd.CommandText = text;

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    return (ActionResult)new OkObjectResult(String.Format("First record for name: {0} is from {1} with count of {2} records.", name,  reader[1], reader[2]));
                }                    
                else
                    return (ActionResult)new OkObjectResult("Nothing found for name: " + name);
            }
        }
    }
    else 
        return new BadRequestObjectResult("Please pass a name on the query string or in the request body");
}