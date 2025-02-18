using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Product.Models.Product
{
    public class CreateProductsModel 
    {
        [Required]
        public string Name { get; set; }
        [Required]
        public Decimal Price { get; set; }
        public string? Brand { get; set; }
        public string? Description { get; set; }
        public string? CategoryIds { get; set; }
        public string? Size {  get; set; }
        public string? Quantity { get; set; }
        public List<IFormFile>? Files { get; set; }
    }
}
