using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WDProject.Models.Product
{
    public class ProductImage
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public string FileName { get; set; }
        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public Products Product { get; set; }
    }
}
