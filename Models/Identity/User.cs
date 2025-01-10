using Microsoft.AspNetCore.Identity;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace WDProject.Models.Identity
{
    public class User : IdentityUser
    {
        [Required]
        [DisplayName("Địa chỉ nhà")]
        public string HomeAddress {  get; set; }
    }
}
