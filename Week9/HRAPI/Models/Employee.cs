namespace HRAPI.Models
{
    public class Employee
    {
        public int EmployeeID { get; set; }
        //ctrl+shift+enter makes a new line below current
        //line and moves your curse to new line
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public DateTime HireDate { get; set; }
        public decimal Salary { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
    }
}
