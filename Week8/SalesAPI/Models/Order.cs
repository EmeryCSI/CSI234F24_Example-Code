using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace SalesAPI.Models
{
    public class Order
    {
        public int Id { get; set; }

        [Required]
        public DateTime OrderDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        // Foreign key for Customer
        public int CustomerId { get; set; }

        // Navigation property
        public virtual Customer? Customer { get; set; }

        // Navigation property
        public virtual ICollection<OrderItem>? OrderItems { get; set; }
    }
}
