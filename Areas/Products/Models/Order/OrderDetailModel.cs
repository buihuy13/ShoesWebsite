using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Product.Models.Order
{
    public class OrderDetailModel
    {
        [Required]
        public string ProductName { get; set; }

        [Required]
        public decimal TotalPrice { get; set; }

        [Required]
        public string imageUrl { get; set; }
        public int Size { get; set; }
        public int Quantity { get; set; }
    }
}
