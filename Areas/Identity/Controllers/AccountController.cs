using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Query.Internal;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Security.Claims;
using System.Text.Json.Serialization;
using Utilities;
using WDProject.Areas.Identity.Models.Account;
using WDProject.Data;
using WDProject.Models.Identity;
using WDProject.Services;

namespace WDProject.Areas.Identity.Controllers
{
    [Area("Identity")]
    public class AccountController : Controller
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private ILogger<AccountController> _logger;
        private readonly TokenService _tokenService;
        public AccountController(UserManager<User> userManager, SignInManager<User> signInManager, ILogger<AccountController> logger,TokenService tokenService)
        {
            _userManager = userManager;         
            _signInManager = signInManager;
            _logger = logger;
            _tokenService = tokenService;
        }

        [HttpPost("/auth/login")]
        public async Task<IActionResult> Login([FromBody]LoginModel model, string returnUrl = null)
        {
            returnUrl ??= Url.Content("~/");
            ViewData["ReturnUrl"] = returnUrl;
            if (!ModelState.IsValid)
            {
                _logger.LogInformation("Received data: {Data}", model.UserNameOrEmail);

                var errors = ModelState.Values
                            .SelectMany(e => e.Errors)
                            .Select(e => e.ErrorMessage)
                            .ToList();
                foreach(var error in errors)
                {
                    _logger.LogInformation(error);
                }
                return BadRequest(new { message = "Dữ liệu không hợp lệ", error = errors });
            }

            // Tìm user bằng username hoặc email
            var user = await _userManager.FindByNameAsync(model.UserNameOrEmail)
                       ?? await _userManager.FindByEmailAsync(model.UserNameOrEmail);

            if (user == null || !(await _userManager.CheckPasswordAsync(user, model.Password)))
            {
                return Unauthorized(new { message = "Tên đăng nhập hoặc mật khẩu không đúng" });
            }

            // Tạo JWT
            var token = await _tokenService.GenerateTokens(user);

            return Ok(new
            {
                message = "Đăng nhập thành công",
                accesstoken = token.AccessToken,
                refreshtoken = token.RefreshToken,
                rememberme = model.RememberMe
            });
        }

        [HttpPost("/auth/logout/{id}")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> LogOut(string? id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user!= null)
            {
                user.RefreshToken = null;
                user.RefreshTokenExpiryTime = DateTime.UtcNow;
            }
            _logger.LogInformation("Đăng xuất thành công");
            return Ok(new { message = "Đăng xuất thành công" });
        }

        [HttpPost("/auth/register")]
        public async Task<IActionResult> Register([FromBody]RegisterModel model, string returnUrl = null)
        {
            returnUrl ??= Url.Content("~/");
            ViewData["ReturnUrl"] = returnUrl;
            if (ModelState.IsValid)
            {
                if (model.Password != model.ConfirmPassword)
                {
                    ModelState.AddModelError("", "Mật khẩu xác nhận không trùng nhau");
                    return BadRequest(new { message = "Mật khẩu và mật khẩu xác nhận không trùng nhau" });
                }
                if (!AppUtilities.IsValidEmail(model.Email))
                {
                    ModelState.AddModelError("", "Email sai định dạng");
                    return BadRequest(new { message = "Sai định dạng Email" });
                }
                var user = new User() { Email = model.Email, UserName = model.UserName, TotalPurchase = 0 };
                var result = await _userManager.CreateAsync(user,model.Password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, RoleName.user);
                    _logger.LogInformation("Tạo tài khoản thành công");
                    return Ok(new { message = "Đăng ký thành công" });
                }
                else
                {
                    ModelState.AddModelError("", result.ToString());
                    return Conflict(new { message = "Đã tồn tại tài khoản này" });
                }
            }
            else
            {
                var errors = ModelState.Values.SelectMany(e => e.Errors);
                foreach (var error in errors)
                {
                    _logger.LogError(error.ErrorMessage);
                    ModelState.AddModelError(string.Empty, error.ErrorMessage);
                }
            }
            return BadRequest(new { message = "Lỗi đăng ký" });
        }

        [HttpPost("/auth/edit")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit([FromBody]EditModel model, string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound(new { message = "Không tìm thấy user" });
            }
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(e => e.Errors);
                foreach (var error in errors)
                {
                    _logger.LogError(error.ErrorMessage);
                    ModelState.AddModelError(string.Empty, error.ErrorMessage);
                }
                return BadRequest(new { message = "Sai định dạng" });
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy user" });
            }
            try
            {
                user.Email = model.Email;
                user.UserName = model.UserName;
                user.HomeAddress = model.HomeAddress;
                await _userManager.UpdateAsync(user);
                return Ok(new { message = "Chỉnh sửa thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                ModelState.AddModelError(string.Empty, ex.Message);
                return BadRequest(new { message = "Lỗi khi chỉnh sửa người dùng" });
            }
        }

        [HttpGet("/auth/getuser/{id}")]
        public async Task<IActionResult> Details(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound(new { message = "Không tìm thấy user" });
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound(new { message = "Không tìm thấy user" });
            }
            return Ok(new { data = JsonConvert.SerializeObject(user) });
        }

        [HttpPost("/auth/delete/{id}")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound(new { message = "Không tìm thấy user" });
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound(new {message = "Không tìm thấy user"});
            }
            try
            {
                await _userManager.DeleteAsync(user);
                return Ok(new { message = "Xóa thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = "Lỗi khi xóa" });
            }
        }
    }
}
