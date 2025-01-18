using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Product.Models.Category
{
    public class CreateModel
    {
        [Required]
        public string Name { get; set; }

        public string? Description { get; set; }
    }
}
