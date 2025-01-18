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

        [ForeignKey("OrderId")]
        public Order? Order {  get; set; }

        [Required]
        public int ProductDetailsId { get; set; }

        [ForeignKey("ProductDetailsId")]
        public ProductDetails? ProductDetails { get; set; }

        [Required]
        public int Quantity { get; set; }
    }
}
