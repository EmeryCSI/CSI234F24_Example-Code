namespace HRAPI.Models
{
    public class EmployeeDepartment
    {
        public int EmployeeID { get; set; }
        public int DepartmentID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsPrimary { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime ModifiedDate { get; set; }
    }
}
