using System.ComponentModel.DataAnnotations;

namespace WDProject.Models.Product
{
    public class Categories
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; }
        public string? Description { get; set; }
        public List<ProductsCategories>? ProductsCategories { get; set; }
    }
}
