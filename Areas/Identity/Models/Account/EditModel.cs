using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Identity.Models.Account
{
    public class EditModel
    {
        [DataType(DataType.EmailAddress), StringLength(50)]
        public string Email { get; set; }
        [StringLength(50)]
        public string UserName { get; set; }

        [StringLength(100)]
        public string? HomeAddress { get; set; }
    }
}
