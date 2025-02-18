using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Identity.Models.Admin
{
    public class CreateModel
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
        [Required]
        [StringLength(50)]
        public string UserName  { get; set; }
        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }
        [StringLength(100)]
        public string? HomeAddress { get; set; }
        public string? Role { get; set; }
    }
}
