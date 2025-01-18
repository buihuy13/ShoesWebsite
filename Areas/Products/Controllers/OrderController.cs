using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System.Runtime.InteropServices;
using WDProject.Models.Database;
using WDProject.Models.Identity;

namespace WDProject.Areas.Product.Controllers
{
    [Authorize]
    [Area("Products")]
    public class OrderController : Controller
    {
        private readonly UserManager<User> _userManager;
        private readonly MyDbContext _dbContext;
        public OrderController(UserManager<User> userManager, MyDbContext dbContext)
        {
            _userManager = userManager;
            _dbContext = dbContext;
        }

        //Danh sách order của 1 user với id là id của user đó
        [HttpGet("/orders/{id}")]
        public async Task<IActionResult> GetOrders(string? id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound(new { message = "Không tìm thấy user để lấy orders" });
            }
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy user để lấy orders" });
            }
            try
            {
                var listorders = _dbContext.Orders.Where(o => o.UserId == user.Id).OrderBy(o => o.OrderDate);
                return Ok(new { data = JsonConvert.SerializeObject(listorders) });
            }
            catch
            {
                return BadRequest(new { message = "Lỗi khi lấy orders" });
            }
        }
        //Details của 1 order
        //Chưa xử lý phần image
        [HttpGet("/orders/details/{id}")]
        public async Task<IActionResult> GetOrderDetails(int? id)
        {
            if (id == null)
            {
                return NotFound(new { message = "Không tìm thấy order" });
            }
            var order = await _dbContext.OrderDetails.Where(o => o.Id == id).Include(o => o.ProductDetails).ThenInclude(pd => pd.Product).FirstOrDefaultAsync();
            if (order == null)
            {
                return NotFound(new { message = "Không tìm thấy order" });
            }
            try
            {
                var images = order.ProductDetails.Product.Images;
                if (images != null && images.Count() > 0)
                {
                    foreach (var image in images)
                    {
                        image.FileName = $"http://localhost:8080/contents/Products/{image.FileName}";
                    }
                }
                return Ok(new { data = JsonConvert.SerializeObject(order) });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
