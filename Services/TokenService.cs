using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using WDProject.Models.Database;
using WDProject.Models.Identity;
using WDProject.Models.Token;

namespace WDProject.Services
{
    public class TokenService
    {
        private readonly IConfiguration _configuration;
        private readonly MyDbContext _context;
        private readonly UserManager<User> _userManager;   

        public TokenService(IConfiguration configuration, MyDbContext context,UserManager<User> userManager)
        {
            _configuration = configuration;
            _context = context;
            _userManager = userManager;
        }

        //Generate cả access token và refresh token cho user được chỉ định
        public async Task<TokenResponse> GenerateTokens(User user)
        {
            var accessToken = await GenerateAccessToken(user);
            var refreshToken = GenerateRefreshToken();

            //Lưu thông tin về refresh token và thời gian hết hạn của nó vào db
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
            await _userManager.UpdateAsync(user);

            return new TokenResponse()
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken
            };
        }

        //Tạo ra mã Access Token
        public async Task<string> GenerateAccessToken(User user)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtConfig:SecretKey"]));
            var credentials = new SigningCredentials(securityKey,SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.UserName),
                new Claim(ClaimTypes.Role, (await _userManager.GetRolesAsync(user)).FirstOrDefault())
            };

            var token = new JwtSecurityToken(
                issuer: _configuration["JwtConfig:Issuer"],
                audience: _configuration["JwtConfig:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(30),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        //Tạo ra mã refresh token
        public string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}
