using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Products.Models.Category
{
    public class CreateModel
    {
        [Required]
        public string Name { get; set; }

        public string? Description { get; set; }
    }
}
