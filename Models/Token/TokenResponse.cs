using System.ComponentModel.DataAnnotations;

namespace WDProject.Models.Token
{
    public class TokenResponse
    {
        [Required]
        public string AccessToken { get; set; }
        [Required]
        public string RefreshToken { get; set; }
    }
}
