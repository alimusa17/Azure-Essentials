using System;
	using System.Data.SqlClient;
	

	public static void Run(TimerInfo myTimer, ILogger log)
	{
	    string constr = "Server=tcp:amsolsqlsrv.database.windows.net,1433,1433;Initial Catalog=amsolsqldb; 
            Persist Security Info=False;
            User ID=demouser;
            Password=demopassword2023@;
            MultipleActiveResultSets=False; Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
	    string sqltext;
	

	    log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
	    //
	    using (SqlConnection conn = new SqlConnection(constr))
	    {
	        conn.Open();
	
	        // Insert a row
	        sqltext = "INSERT INTO SubmittedItems (SubmittedName) VALUES ('TIMER')";
	

	        using (SqlCommand cmd = new SqlCommand(sqltext, conn))
	        {
	            cmd.ExecuteNonQuery();
	        }
	
	    }
	}
