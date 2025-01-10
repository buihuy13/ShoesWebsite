using WDProject.Models.Identity;

namespace WDProject.Areas.Identity.Models.Admin
{
    public class UserModel
    {
        public List<User>? Users { get; set; }
        public int totalUsers { get; set; }
        public int countPages { get; set; }
        public int ITEMS_PER_PAGE { get; set; } = 20;
        public int currentPage { get; set; }
    }
}
