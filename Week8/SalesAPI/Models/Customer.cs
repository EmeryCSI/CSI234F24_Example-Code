using System.ComponentModel.DataAnnotations;

namespace SalesAPI.Models
{
    public class Customer
    {
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string FirstName { get; set; }

        [Required]
        [StringLength(50)]
        public string LastName { get; set; }

        [EmailAddress]
        public string Email { get; set; }

        // Navigation property
        public virtual ICollection<Order>? Orders { get; set; }
    }
}
