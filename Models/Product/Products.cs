using System.ComponentModel.DataAnnotations;

namespace WDProject.Models.Product
{
    public class Products
    {
        [Key]
        public int Id { get; set; }
        [Required]  
        public string Name { get; set; }
        [Required]
        public Decimal Price { get; set; }

        [Required]
        public string Description { get; set; } 
        public List<ProductDetails> Details { get; set; }
        public List<ProductsCategories>? ProductsCategories { get; set; }
        public string? ImageUrl { get; set; }
    }
}
