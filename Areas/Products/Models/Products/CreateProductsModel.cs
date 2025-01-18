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
        public List<int>? CategoryIds { get; set; }

        [DataType(DataType.Upload)]
        [FileExtensions(Extensions = "png,jpg,jpeg,gif")]
        public List<IFormFile>? Files { get; set; }
    }
}
