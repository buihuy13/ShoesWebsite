using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WDProject.Models.Product
{
    public class ProductDetails
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public Products? Product { get; set; }

        [Required]
        public int Size { get; set; }

        [Required]
        public int StockQuantity { get; set; }
        public List<OrderDetails>? OrderDetails { get; set; }
    }
}
