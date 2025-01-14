using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Identity.Models.Account
{
    public class LoginModel
    {
        public string UserNameOrEmail { get; set; }

        [DataType(DataType.Password)]
        public string Password { get; set; }
        public bool RememberMe { get; set; }
    }
}
