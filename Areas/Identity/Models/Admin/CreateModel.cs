using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Identity.Models.Admin
{
    public class CreateModel
    {
        [DataType(DataType.EmailAddress),StringLength(50)]
        public string Email { get; set; }
        [StringLength(50)]
        public string UserName  { get; set; }
        [DataType(DataType.Password)]
        public string Password { get; set; }
        [StringLength(100)]
        public string? HomeAddress { get; set; }
    }
}
