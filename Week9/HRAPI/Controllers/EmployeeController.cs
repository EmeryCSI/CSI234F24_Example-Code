using Microsoft.AspNetCore.Mvc;
using Dapper;
using System.Data.SqlClient;
using HRAPI.Models;
using System.Collections.Generic;
using System.Numerics;

namespace HRAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmployeeController : Controller
    {
        //lets try to get our connection string out of appsettings.json
        string connectionString;
        public EmployeeController(IConfiguration configuration)
        {
            connectionString = configuration.GetConnectionString("DefaultConnection");
        }
        //Get All Employees
        [HttpGet]
        public IActionResult Index()
        {
            using SqlConnection connection = new SqlConnection(connectionString);
            //here is where we use Dapper
            List<Employee> employees = connection.Query<Employee>("SELECT * FROM HR.Employee").ToList();
            return Ok(employees);
        }
        //Get By Id
        [HttpGet("{id}")]
        public IActionResult Details(int id)
        {
            using SqlConnection connection = new SqlConnection(connectionString);
            //here is where we use Dapper
            //Using Parameterized Queries to avoid SQL Injection
            Employee? employee = connection.QueryFirstOrDefault<Employee>("SELECT * FROM HR.Employee WHERE EmployeeID = @Id", new {Id = id});
            if(employee == null)
            {
                return NotFound();
            }
            return Ok(employee);
        }
        //Create Employee
        //query<ModelName> - List of ModelName
        //queryfirstorDefault<ModelName> - List one ModelName or null
        //querysingle<ModelName> One result that you know exists - commonly use after create
        [HttpPost]
        public IActionResult CreateEmployee(Employee employee)
        {
            //validate the employee
            /* INSERT INTO[HR].[Employee](FirstName, LastName, Email, Phone, HireDate, Salary) VALUES
    ('John', 'Doe', 'john.doe@company.com', '555-0101', '2020-01-15', 75000.00) */
            using SqlConnection connection = new SqlConnection(connectionString);
            Employee newEmployee = connection.QuerySingle<Employee>(
                "INSERT INTO[HR].[Employee](FirstName, LastName, Email, Phone, HireDate, Salary) " +
                "VALUES (@FirstName, @LastName, @Email, @Phone, @HireDate, @Salary);" + 
                "SELECT * FROM HR.Employee WHERE EmployeeID = SCOPE_IDENTITY();"
                , employee);

            return Ok(newEmployee);
        }

    }
}
