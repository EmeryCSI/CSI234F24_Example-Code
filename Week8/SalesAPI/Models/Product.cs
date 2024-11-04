using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace SalesAPI.Models
{
    public class Product
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public required string Name { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }

        // Navigation property
        public virtual ICollection<OrderItem>? OrderItems { get; set; }
    }
}
