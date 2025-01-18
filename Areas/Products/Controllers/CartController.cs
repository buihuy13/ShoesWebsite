using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using WDProject.Areas.Product.Models.Cart;
using WDProject.Models.CartModel;
using WDProject.Models.Database;
using WDProject.Models.Identity;
using WDProject.Models.Product;
using WDProject.Services;

namespace WDProject.Areas.Product.Controllers
{
    public class CartController : Controller
    {
        private readonly CartService _cartService;
        private readonly MyDbContext _dbContext;
        private readonly UserManager<User> _userManager;

        public CartController(CartService cartService, MyDbContext dbContext, UserManager<User> userManager)
        {
            _cartService = cartService;
            _dbContext = dbContext;
            _userManager = userManager;
        }
        [HttpGet("/cart")]
        public IActionResult GetCartItems()
        {
            var items = _cartService.GetItems();
            return Ok(new 
            { 
                data = items 
            });
        }

        [HttpPost("/cart")]
        public async Task<IActionResult> AddCartItems([FromBody]CartModel cartModel)
        {
            if (cartModel.Id == null)
            {
                return NotFound(new { message = "Không tồn tại product" });
            }
            var product = await _dbContext.ProductDetails.Include(p => p.Product).ThenInclude(p => p.Images).FirstOrDefaultAsync(p => p.Id == cartModel.Id);
            if (product == null)
            {
                return NotFound(new { message = "Không tồn tại product" });
            }
            try
            {
                var cartItems = _cartService.GetItems();
                var item = cartItems.FirstOrDefault(c => c.Product.Id == cartModel.Id);
                if (item == null)
                {
                    cartItems.Add(new CartItem()
                    {
                        Product = product,
                        Quantity = 1
                    });
                }
                else
                {
                    item.Quantity++;
                }
                _cartService.SaveCart(cartItems);
                return Ok(new { message = "Thêm thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("/cart")]
        public IActionResult DeleteCartItems([FromBody]CartModel cartModel)
        {
            if (cartModel.Id == null)
            {
                return NotFound(new { message = "Không tồn tại product" });
            }
            try
            {
                var cartItems = _cartService.GetItems();
                var item = cartItems.FirstOrDefault(c => c.Product.Id == cartModel.Id);
                if (item == null)
                {
                    return NotFound(new { message = "Không tìm thấy item cần xóa" });
                }
                cartItems.Remove(item);
                _cartService.SaveCart(cartItems);
                return Ok(new { message = "Xóa thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("/cart")]
        public IActionResult UpdateCart([FromBody]CartModel cartModel)
        {
            if (cartModel.Id == null)
            {
                return NotFound(new { message = "Không được để null" });
            }
            var items = _cartService.GetItems();
            var item = items.FirstOrDefault(c => c.Product.Id == cartModel.Id);
            if (item == null)
            {
                return NotFound(new { message = "Không tìm thấy product trong cart" });
            }
            if (cartModel.Quantity == 0)
            {
                items.Remove(item);
            }
            else
            {
                item.Quantity = cartModel.Quantity;
            }
            _cartService.SaveCart(items);
            return Ok(new { message = "update thành công" });
        }

        [HttpPost("/cart/new")]
        //id của user
        public async Task<IActionResult> NewCart([FromBody]string? id)
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
            if (string.IsNullOrEmpty(user.HomeAddress) || string.IsNullOrEmpty(user.PhoneNumber))
            {
                return BadRequest(new { message = "Điền đầy đủ thông tin cá nhân" });
            }
            try
            {
                var items = _cartService.GetItems();
                decimal totalMoney = 0;
                foreach (var item in items)
                {
                    totalMoney += item.Product.Product.Price * item.Quantity;
                }
                var newOrder = new Order()
                {
                    UserId = id,
                    OrderDate = DateTime.Now,
                    ShippingAddress = user.HomeAddress,
                    TotalPrice = totalMoney,
                };
                await _dbContext.AddAsync(newOrder);

                foreach (var item in items)
                {
                    await _dbContext.AddAsync(new OrderDetails()
                    {
                        Order = newOrder,
                        ProductDetails = item.Product,
                        Quantity = item.Quantity
                    });
                    if (item.Quantity > item.Product.StockQuantity)
                    {
                        return BadRequest(new { message = "Số lượng mua lớn hơn số lượng tồn kho" });
                    }
                    item.Product.StockQuantity -= item.Quantity;
                }
                _cartService.ClearCart();
                await _dbContext.SaveChangesAsync();
                return Ok(new { message = "Mua hàng thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(new {message = ex.Message});
            }
        }
    }
}
