using Microsoft.Data.SqlClient;
namespace SqlConnect
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
            //Connection String
            //Where is your server. What database do you wanna query.
            //How are you authenticating
            //const string CONNECTION_STRING = "Server=(localdb)\\MSSQLLocalDB;Database=AdventureWorksLT2019;Integrated Security=true";
            //What if we wanted to login as a user
            const string CONNECTION_STRING = "Server=(localdb)\\MSSQLLocalDB;Database=AdventureWorksLT2019;User Id=UserName;Password=P@ssword";
            //Create a SQLConnection object with the string
            SqlConnection connection = new SqlConnection(CONNECTION_STRING);
            //try to open a connection
            try
            {
                connection.Open();
                //if you make it down here connection was successfull
                Console.WriteLine("Connection to database successful");
                //We make a SQLCommandObject and we try to run it
                string sql = "SELECT * FROM SalesLT.Customer";
                //You could also run stored procedures
                //SqlCommand command = new SqlCommand("StoredProcedureName", connection);
                //SqlCommand command = new SqlCommand("SalesLT.GetProductsByCategory", connection);
                //command.CommandType = CommandType.StoreProcedure;
                //SqlCommand takes a query and a connection
                SqlCommand command = new SqlCommand(sql, connection);
                //we try to execute the command and read the results
                try
                {
                    SqlDataReader reader = command.ExecuteReader();
                    //The reader object contains all of the rows of the result of the query
                    while (reader.Read())
                    {
                        //get the values by the column name
                        string firstName = reader["FirstName"].ToString();
                        string lastName = reader["LastName"].ToString();
                        string emailAddress = reader["EmailAddress"].ToString();
                        //print them out
                        Console.Write($"First Name: {firstName} Last Name: {lastName} Email Address: {emailAddress}\n");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Query Failed ${ex.Message}");
                }
                finally
                {
                    //close the command
                    command.Dispose();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Connection failed {ex.Message}");
            }
            finally
            {
                connection.Close();
            }
            Console.ReadLine();
        }
    }
}