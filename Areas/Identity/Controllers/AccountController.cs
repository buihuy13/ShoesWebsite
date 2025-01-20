using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Utilities;
using WDProject.Areas.Identity.Models.Account;
using WDProject.Data;
using WDProject.Models.Database;
using WDProject.Models.Identity;
using WDProject.Models.Token;
using WDProject.Services;

namespace WDProject.Areas.Identity.Controllers
{
    [Area("Identity")]
    public class AccountController : Controller
    {
        private readonly string _secretKey;
        private readonly UserManager<User> _userManager;
        private ILogger<AccountController> _logger;
        private readonly MyDbContext _dbContext;
        private readonly TokenService _tokenService;
        public AccountController(UserManager<User> userManager, MyDbContext dbContext, ILogger<AccountController> logger, TokenService tokenService,IOptions<JwtKey> jwtKey)
        {
            _userManager = userManager;
            _dbContext = dbContext;
            _logger = logger;
            _tokenService = tokenService;
            _secretKey = jwtKey.Value.SecretKey;
        }

        [HttpPost("/auth/login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                            .SelectMany(e => e.Errors)
                            .Select(e => e.ErrorMessage)
                            .ToList();
                foreach (var error in errors)
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
            if (token == null)
            {
                return BadRequest(new { message = "Dữ liệu không hợp lệ" });
            }

            var userData = new
            {
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                UserName = user.UserName,
                Id = user.Id,
                Role = (await _userManager.GetRolesAsync(user)).FirstOrDefault()
            };

            return Ok(new
            {
                message = "Đăng nhập thành công",
                accesstoken = token.AccessToken,
                refreshtoken = token.RefreshToken,
                rememberme = model.RememberMe,
                user = userData
            });
        }

        [HttpPost("/api/accesstoken")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            try
            {
                var user = _userManager.Users.FirstOrDefault(u => u.RefreshToken == request.RefreshToken);

                if (user == null)
                {
                    return Unauthorized(new { message = "Invalid refresh token" });
                }

                if (user.RefreshTokenExpiryTime <= DateTime.UtcNow)
                {
                    return BadRequest(new { message = "Refresh token expired" });
                }

                var tokens = await _tokenService.GenerateTokens(user);
                await _userManager.UpdateAsync(user);

                return Ok(new
                {
                    accessToken = tokens.AccessToken,
                    refreshToken = tokens.RefreshToken
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error refreshing token");
                return BadRequest(new { message = "Không thể trả về tokens mới" });
            }
        }

        [HttpPost("/auth/logout/{id}")]
        [Authorize]
        public async Task<IActionResult> LogOut(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound(new { message = "Không tìm thấy user" });
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user != null)
            {
                user.RefreshToken = null;
                user.RefreshTokenExpiryTime = DateTime.UtcNow;
                await _userManager.UpdateAsync(user);
            }
            _logger.LogInformation("Đăng xuất thành công");
            return Ok(new { message = "Đăng xuất thành công" });
        }

        [HttpPost("/auth/register")]
        public async Task<IActionResult> Register([FromBody] RegisterModel model)
        {
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
                var result = await _userManager.CreateAsync(user, model.Password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, RoleName.user);
                    _logger.LogInformation("Tạo tài khoản thành công");
                    return StatusCode(201,new { message = "Đăng ký thành công" });
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

        [HttpPut("/users/{id}")]
        [Authorize]
        public async Task<IActionResult> Edit([FromBody] EditModel model)
        {
            if (string.IsNullOrEmpty(model.Id))
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
            var user = await _userManager.FindByIdAsync(model.Id);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy user" });
            }
            try
            {
                user.Email = model.Email;
                user.UserName = model.UserName;
                user.HomeAddress = model.HomeAddress;
                user.PhoneNumber = model.PhoneNumber;
                await _userManager.UpdateAsync(user);
                await _dbContext.SaveChangesAsync();
                return Ok(new { message = "Chỉnh sửa thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                ModelState.AddModelError(string.Empty, ex.Message);
                return BadRequest(new { message = "Lỗi khi chỉnh sửa người dùng" });
            }
        }

        [HttpGet("/users/{id}")]
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
            return Ok(new { data = new
            {
                HomeAddress = user.HomeAddress,
                UserName = user.UserName,
                TotalPurchase = user.TotalPurchase,
                Phone = user.PhoneNumber,
            }
            });
        }

        [HttpDelete("/users/{id}")]
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
                return NotFound(new { message = "Không tìm thấy user" });
            }
            try
            {
                await _userManager.DeleteAsync(user);
                await _dbContext.SaveChangesAsync();
                return Ok(new { message = "Xóa thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = "Lỗi khi xóa" });
            }
        }

            [HttpGet("/auth/account")]
            public async Task<IActionResult> GetUserByToken()
            {
                try
                {
                    var token = Request.Headers["Authorization"].FirstOrDefault()?.Split(" ").Last();
                    if (string.IsNullOrEmpty(token))
                    {
                        return NotFound(new { message = "Không tìm thấy token trong header" });
                    }
                var tokenHandler = new JwtSecurityTokenHandler();
                    var key = Encoding.ASCII.GetBytes(_secretKey);

                    // Validate token và lấy thông tin claims
                    var validationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(key),
                        ValidateIssuer = false,
                        ValidateAudience = false,
                        ClockSkew = TimeSpan.Zero
                    };

                    ClaimsPrincipal claimsPrincipal = tokenHandler.ValidateToken(token, validationParameters, out SecurityToken validatedToken);

                    // Lấy user ID từ claims
                    var userIdClaim = claimsPrincipal.Claims.FirstOrDefault(x => x.Type == ClaimTypes.NameIdentifier);
                
                    if (userIdClaim == null)
                    {
                        return NotFound(new { message = "Không tìm thấy user" });
                    }

                    var userId = userIdClaim.Value;

                    // Lấy user từ database
                    var user = await _userManager.FindByIdAsync(userId);
                    if (user == null)
                    {
                        return NotFound(new { message = "Không tìm thấy user" });
                    }
                    var data = new
                    {
                        Email = user.Email,
                        PhoneNumber = user.PhoneNumber,
                        UserName = user.UserName,
                        Id = user.Id,
                        Role = (await _userManager.GetRolesAsync(user)).FirstOrDefault()
                    };
                return Ok(new {data});
                }
                catch (SecurityTokenExpiredException)
                {
                    return StatusCode(401, new { message = "Token đã hết hạn" });
                }
                catch (Exception ex)
                {
                    return BadRequest(new { message = ex.Message });
                }
            }
    }
}
