using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Query.Internal;
using Newtonsoft.Json;
using Utilities;
using WDProject.Areas.Identity.Models.Account;
using WDProject.Data;
using WDProject.Models.Identity;
using WDProject.Services;

namespace WDProject.Areas.Identity.Controllers
{
    [Area("Identity")]
    [Route("/Account/[action]")]
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

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginModel model, string returnUrl = null)
        {
            returnUrl ??= Url.Content("~/");
            ViewData["ReturnUrl"] = returnUrl;
            if (ModelState.IsValid)
            {
                var result = await _signInManager.PasswordSignInAsync(model.UserNameOrEmail, model.Password, model.RememberMe, lockoutOnFailure: false);
                var user = await _userManager.FindByNameAsync(model.UserNameOrEmail);
                if ((!result.Succeeded) && AppUtilities.IsValidEmail(model.UserNameOrEmail))
                {
                    user = await _userManager.FindByEmailAsync(model.UserNameOrEmail);
                    if (user != null)
                    {
                        result = await _signInManager.PasswordSignInAsync(user.UserName, model.Password, model.RememberMe, lockoutOnFailure: true);
                    }
                }
                if (result.Succeeded)
                {
                    _logger.LogInformation("Đăng nhập thành công");
                    var JwtTokens = _tokenService.GenerateTokens(user);
                    return Ok(new { 
                        message = "Đăng nhập thành công",
                        tokens = JwtTokens
                    });
                }
                else
                {
                    _logger.LogWarning("Đăng nhập thất bại");
                    ModelState.AddModelError("", "Lỗi đăng nhập");
                    return Unauthorized(new { message = "Đăng nhập không thành công" });
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
            return Unauthorized(new { message = "Đăng nhập không thành công" });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> LogOut()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user!= null)
            {
                user.RefreshToken = null;
                user.RefreshTokenExpiryTime = DateTime.UtcNow;
            }
            await _signInManager.SignOutAsync();
            _logger.LogInformation("Đăng xuất thành công");
            return Ok(new { message = "Đăng xuất thành công" });
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Register(RegisterModel model, string returnUrl = null)
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
                if (AppUtilities.IsValidEmail(model.Email))
                {
                    ModelState.AddModelError("", "Email sai định dạng");
                    return BadRequest(new { message = "Sai định dạng Email" });
                }
                var user = new User() { Email = model.Email, UserName = model.UserName };
                var result = await _userManager.CreateAsync(user,model.Password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, RoleName.user);
                    _logger.LogInformation("Tạo tài khoản thành công");
                    await _signInManager.SignInAsync(user, isPersistent: false);
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

        [HttpGet]
        public async Task<IActionResult> Edit(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound(new { message = "Không tìm thấy user" });
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy user" });
            }
            var model = new EditModel()
            {
                UserName = user.UserName,
                Email = user.Email,
                HomeAddress = user.HomeAddress
            };
            return Ok(new { data = JsonConvert.SerializeObject(model) });
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(EditModel model, string? id)
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

        [HttpGet]
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

        [HttpGet]
        public async Task<IActionResult> Delete(string? id)
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

        [HttpPost]
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
