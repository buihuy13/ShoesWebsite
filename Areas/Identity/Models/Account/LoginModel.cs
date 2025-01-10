using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Identity.Models.Account
{
    public class LoginModel
    {
        [Required]
        [StringLength(50)]
        public string UserNameOrEmail { get; set; }
        [Required]
        [DisplayName("Password")]
        [DataType(DataType.Password)]
        public string Password { get; set; }
        [DisplayName("Nhớ thông tin đăng nhập")]
        public bool RememberMe { get; set; }
    }
}
