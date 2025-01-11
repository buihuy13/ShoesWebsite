using Microsoft.AspNetCore.Identity;
using WDProject.Data;
using WDProject.Models.Database;
using WDProject.Models.Identity;

namespace WDProject.Helpers
{
    public class FakeData
    {
        private readonly UserManager<User> userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly MyDbContext _context;
        private readonly ILogger<FakeData> _logger;

        public FakeData(UserManager<User> userManager, RoleManager<IdentityRole> roleManager, MyDbContext context, ILogger<FakeData> logger)
        {
            this.userManager = userManager;
            _roleManager = roleManager;
            _context = context;
            _logger = logger;
        }
        public async void FakeDataFunction()
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
                        return;
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
                    Total_Purchase = 0
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
                    Total_Purchase = 0
                };
                var userResult = await userManager.CreateAsync(user, "user123");
                await userManager.AddToRoleAsync(user, RoleName.user);
                if (!userResult.Succeeded)
                {
                    _logger.LogWarning("Tạo user thất bại");
                }
            }
            return;
        }
    }
}
