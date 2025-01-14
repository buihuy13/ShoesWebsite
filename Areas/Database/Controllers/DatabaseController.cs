using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using WDProject.Data;
using WDProject.Models.Database;
using WDProject.Models.Identity;
namespace ShoesWebsite.Areas.Database.Controllers
{
    [Area("Database")]
    [Route("/Database/[action]")]
    [Authorize(Roles = RoleName.admin)] 
    public class DatabaseController : Controller
    {
        private readonly UserManager<User> userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly ILogger<DatabaseController> _logger;
        private readonly MyDbContext _context;

        public DatabaseController(UserManager<User> userManager, RoleManager<IdentityRole> roleManager, ILogger<DatabaseController> logger, MyDbContext context)
        {
            this.userManager = userManager;
            _roleManager = roleManager;
            _logger = logger;
            _context = context;
        }
        public IActionResult Index()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> FakeUser()
        {
            var roles = typeof(RoleName).GetFields().ToList();
            foreach (var role in roles)
            {
                var roleName = (string)role.GetRawConstantValue();
                var roleFound = _roleManager.FindByNameAsync(roleName);
                if (roleFound == null)
                {
                    var result = await _roleManager.CreateAsync(new IdentityRole(roleName));
                    if (!result.Succeeded)
                    {
                        _logger.LogWarning("Lỗi khi tạo role");
                        return RedirectToAction("View");
                    }
                }
            }
            var adminUserFind = userManager.FindByEmailAsync("admin123@gmail.com");
            var userFind = userManager.FindByEmailAsync("user123@gmail.com");
            if (adminUserFind == null)
            {
                var adminUser = new WDProject.Models.Identity.User()
                {
                    UserName = "admin",
                    Email = "admin123@gmail.com",
                    TotalPurchase = 0
                };
                var adminResult = await userManager.CreateAsync(adminUser, "admin123");
                await userManager.AddToRoleAsync(adminUser, RoleName.admin);
                if (!adminResult.Succeeded)
                {
                    _logger.LogWarning("Tạo admin thất bại");
                }
            }
            if (adminUserFind == null)
            {
                var user = new WDProject.Models.Identity.User()
                {
                    UserName = "user",
                    Email = "user123@gmail.com",
                    TotalPurchase = 0
                };
                var userResult = await userManager.CreateAsync(user, "user123");
                await userManager.AddToRoleAsync(user, RoleName.user);
                if (!userResult.Succeeded)
                {
                    _logger.LogWarning("Tạo user thất bại");
                }
            }
            return RedirectToAction("View");
        }
    }
}
