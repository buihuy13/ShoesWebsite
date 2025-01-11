using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WDProject.Models.Product
{
    public class OrderDetails
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int OrderId { get; set; }

        [Required]
        [ForeignKey("OrderId")]
        public int Order {  get; set; }

        [Required]
        public int ProductId { get; set; }

        [Required]
        [ForeignKey("ProductId")]
        public Products Product { get; set; }

        [Required]
        public int Quantity { get; set; }
    }
}
