using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Utilities;
using WDProject.Areas.Identity.Models.Account;
using WDProject.Data;
using WDProject.Models.Identity;

namespace WDProject.Areas.Identity.Controllers
{
    [Area("Identity")]
    [Route("/Account/[action]")]
    public class AccountController : Controller
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private ILogger<AccountController> _logger;
        public AccountController(UserManager<User> userManager, SignInManager<User> signInManager, ILogger<AccountController> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _logger = logger;
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
                if ((!result.Succeeded) && AppUtilities.IsValidEmail(model.UserNameOrEmail))
                {
                    var user = await _userManager.FindByEmailAsync(model.UserNameOrEmail);
                    if (user != null)
                    {
                        result = await _signInManager.PasswordSignInAsync(user.UserName, model.Password, model.RememberMe, lockoutOnFailure: true);
                    }
                }
                if (result.Succeeded)
                {
                    _logger.LogInformation("Đăng nhập thành công");
                    return LocalRedirect(returnUrl);
                }
                else
                {
                    _logger.LogWarning("Đăng nhập thất bại");
                    ModelState.AddModelError("", "Lỗi đăng nhập");
                    return Unauthorized("Đăng nhập không thành công");
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
            return Unauthorized("Sai định dạng");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> LogOut()
        {
            await _signInManager.SignOutAsync();
            _logger.LogInformation("Đăng xuất thành công");
            return Redirect("/Account/Login");
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
                    return BadRequest("Mật khẩu và mật khẩu xác nhận không trùng nhau");
                }
                if (AppUtilities.IsValidEmail(model.Email))
                {
                    ModelState.AddModelError("", "Email sai định dạng");
                    return BadRequest("Sai định dạng Email");
                }
                var user = new User() { Email = model.Email, UserName = model.UserName };
                var result = await _userManager.CreateAsync(user,model.Password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, RoleName.user);
                    _logger.LogInformation("Tạo tài khoản thành công");
                    await _signInManager.SignInAsync(user, isPersistent: false);
                    return LocalRedirect(returnUrl);
                }
                else
                {
                    ModelState.AddModelError("", result.ToString());
                    return Conflict("Đã tồn tại tài khoản này");
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
            return BadRequest("Sai định dạng");
        }

        [HttpGet]
        public async Task<IActionResult> Edit(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound("Không tìm thấy user");
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound("Không tìm thấy user");
            }
            var model = new EditModel()
            {
                UserName = user.UserName,
                Email = user.Email,
                HomeAddress = user.HomeAddress
            };
            return Json(model);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(EditModel model, string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound("Không tìm thấy user");
            }
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(e => e.Errors);
                foreach (var error in errors)
                {
                    _logger.LogError(error.ErrorMessage);
                    ModelState.AddModelError(string.Empty, error.ErrorMessage);
                }
                return BadRequest(model);
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound("Không tìm thấy user");
            }
            try
            {
                user.Email = model.Email;
                user.UserName = model.UserName;
                user.HomeAddress = model.HomeAddress;
                await _userManager.UpdateAsync(user);
                return Redirect("/HomePage");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                ModelState.AddModelError(string.Empty, ex.Message);
                return BadRequest("Lỗi khi chỉnh sửa người dùng");
            }
        }

        [HttpGet]
        public async Task<IActionResult> Details(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound("Không tìm thấy user");
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound("Không tìm thấy user");
            }
            return Json(user);
        }

        [HttpGet]
        public async Task<IActionResult> Delete(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound("Không tìm thấy user");
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound("Không tìm thấy user");
            }
            return Json(user);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound("Không tìm thấy user");
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                _logger.LogInformation("Không tìm thấy user");
                return NotFound("Không tìm thấy user");
            }
            try
            {
                await _userManager.DeleteAsync(user);
                return Redirect("/Account/Register");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest("Lỗi khi xóa người dùng");
            }
        }
    }
}
