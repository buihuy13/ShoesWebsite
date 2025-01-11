using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WDProject.Models.Product
{
    public class ProductsCategories
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int ProductId { get; set; }

        [Required]
        public int CategoryId { get; set; }

        [Required]
        [ForeignKey("ProductId")]
        public Products Product {  get; set; }

        [Required]
        [ForeignKey("CategoryId")]
        public Categories Category { get; set; }
    }
}
