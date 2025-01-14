using Microsoft.AspNetCore.Identity;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using WDProject.Models.Product;

namespace WDProject.Models.Identity
{
    public class User : IdentityUser
    {
        [DisplayName("Địa chỉ nhà")]
        public string? HomeAddress { get; set; }
        public string? RefreshToken { get; set; }
        public DateTime RefreshTokenExpiryTime { get; set; }
        [Required]
        public Decimal TotalPurchase {  get; set; }
        public List<Order>? Orders { get; set; }
    }
}
