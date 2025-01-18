using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Product.Models.ProductDetail
{
    public class CreateDetailModel
    {
        [Required]
        public int Size { get; set; }
        [Required]
        public string Color { get; set; }
        [Required]
        public int StockQuantity { get; set; }
    }
}
