#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Data.SqlClient;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string constr = "Server=tcp:amsolsqlsrv.database.windows.net,1433,1433;Initial Catalog=amsolsqldb;Persist Security Info=False;User 
ID=demouser;
Password=demopassword2023@;
MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
    string sqltext;

    string name = req.Query["name"];

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    name = name ?? data?.name;

    if (name != null) 
    {
        using (SqlConnection conn = new SqlConnection(constr))
        {
            conn.Open();

            // Insert a row
            sqltext = "INSERT INTO SubmittedItems (SubmittedName) VALUES ('" + name + "')";

            using (SqlCommand cmd = new SqlCommand(sqltext, conn))
            {
                await cmd.ExecuteNonQueryAsync();
            }

            // Query the database
            sqltext = "SELECT SubmittedName, MIN(SubmissionTime), COUNT(SubmittedName) FROM SubmittedItems WHERE SubmittedName='" + name + "' GROUP BY SubmittedName";
            
            using (SqlCommand cmd = new SqlCommand(sqltext, conn))
            {
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    return (ActionResult)new OkObjectResult(String.Format("{0} has {2} copies and the first one was inserted on {1}", reader[0], reader[1], reader[2]));
                }                    
                else
                    return (ActionResult)new OkObjectResult("Nothing found for " + name);
            }
        }
    }
    else 
        return new BadRequestObjectResult("Please pass a name on the query string or in the request body");
}
