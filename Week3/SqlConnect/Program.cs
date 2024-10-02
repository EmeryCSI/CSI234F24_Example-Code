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
            const string CONNECTION_STRING = "Server=(localdb)\\MSSQLLocalDB;Database=AdventureWorksLT2019;Integrated Security=true";
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
                //SqlCommand takes a query and a connection
                SqlCommand command = new SqlCommand(sql, connection);
                //we try to execute the command and read the results
                try
                {
                    SqlDataReader reader = command.ExecuteReader();
                    //The reader object contains all of the rows of the result of the query
                    while (reader.Read())
                    {
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            //reader .getvalue gets you the value at the first column
                            //when i is 0, second when i is 1
                            Console.Write(reader.GetValue(i) + "\t");
                        }
                        Console.WriteLine();
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
