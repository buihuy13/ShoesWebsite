using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WDProject.Areas.Identity.Models.Admin;
using WDProject.Data;
using WDProject.Models.Database;
using WDProject.Models.Identity;

namespace ShoesWebsite.Areas.Identity.Controllers
{
    [Area("Identity")]
    [Authorize(Roles = RoleName.admin)]
    public class AdminController : Controller
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private readonly ILogger<AdminController> _logger;
        private readonly RoleManager<IdentityRole> roleManager;
        private readonly MyDbContext _dbContext;
        public AdminController(UserManager<User> userManager, SignInManager<User> signInManager, 
                               ILogger<AdminController> logger, RoleManager<IdentityRole> roleManager, MyDbContext dbContext)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _logger = logger;
            this.roleManager = roleManager;
            _dbContext = dbContext;
        }
        [HttpGet("/admin/users")]
        public async Task<IActionResult> Index([FromQuery(Name = "p")] int currentPage)
        {
            try
            {
                var model = new UserModel();
                model.currentPage = currentPage;
                var user = await _userManager.GetUserAsync(this.User);
                if (user == null)
                {
                    return Unauthorized(new { message = "lỗi" });
                }
                var adminUserId = await _userManager.GetUserIdAsync(user);
                var userList = _userManager.Users.Where(u => u.Id != adminUserId).ToList();

                model.totalUsers = userList.Count;
                model.countPages = (int)Math.Ceiling((double)model.totalUsers / model.ITEMS_PER_PAGE);

                if (model.currentPage < 1)
                    model.currentPage = 1;
                if (model.currentPage > model.countPages)
                    model.currentPage = model.countPages;

                var qr = userList.Skip((model.currentPage - 1) * model.ITEMS_PER_PAGE).Take(model.ITEMS_PER_PAGE);
                model.Users = qr.ToList();

                var response = model.Users.Select(u => new
                {
                    Id = u.Id,
                    UserName = u.UserName,
                    Email = u.Email,
                    TotalPurchase = u.TotalPurchase,
                    HomeAddress = u.HomeAddress,
                    PhoneNumber = u.PhoneNumber
                });

                return Ok(new
                {
                    data = response,
                    Currentpage = model.currentPage,
                    TotalPage = model.countPages,
                });
            }
            catch (Exception ex)
            {
                _logger.LogInformation(ex.Message);
                return BadRequest("Không tạo ra list các user được");
            }
        }

        [HttpPost("/admin/new")]
        public async Task<IActionResult> Create([FromBody] CreateModel model)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(e => e.Errors);
                foreach (var error in errors)
                {
                    _logger.LogError(error.ErrorMessage);
                    ModelState.AddModelError(string.Empty, error.ErrorMessage);
                }
                return BadRequest(new { message = "Có lỗi khi tạo người dùng" });
            }
            try
            {
                var user = new User()
                {
                    UserName = model.UserName,
                    Email = model.Email,
                    EmailConfirmed = true,
                    TotalPurchase = 0
                };
                await _userManager.CreateAsync(user, model.Password);
                if (model.Role == "Admin")
                {
                    await _userManager.AddToRoleAsync(user, RoleName.admin);
                }
                else
                {
                    await _userManager.AddToRoleAsync(user, RoleName.user);
                }
                return StatusCode(201, new { message = "Tạo người dùng thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = "Có lỗi khi tạo người dùng" });
            }
        }

        [HttpGet("/admin/details")]
        public async Task<IActionResult> GetDetails()
        {
            try
            {
                var orderCount = await _dbContext.Orders.CountAsync();
                var userCount = await _dbContext.Users.CountAsync();
                var productCount = await _dbContext.Products.CountAsync();

                return Ok(new
                {
                    OrderCount = orderCount,
                    UserCount = userCount,
                    ProductCount = productCount
                });
            }
            catch
            {
                return BadRequest(new { message = "Lỗi khi lấy details" });
            }
        }
    }
}
