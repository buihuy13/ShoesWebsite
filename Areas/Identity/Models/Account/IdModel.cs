using System.ComponentModel.DataAnnotations;

namespace WDProject.Areas.Identity.Models.Account
{
    public class IdModel
    {
        [Required]
        public string Id { get; set; }
    }
}
