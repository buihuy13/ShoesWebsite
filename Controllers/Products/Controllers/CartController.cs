﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WDProject.Areas.Product.Models.Cart;
using WDProject.Models.CartModel;
using WDProject.Models.Database;
using WDProject.Models.Identity;
using WDProject.Models.Product;
using WDProject.Services;

namespace WDProject.Areas.Product.Controllers
{
    [Authorize]
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
            foreach (var item in items)
            {
                if (item.Product.Product != null && item.Product.Product.Images != null)
                {
                    foreach (var image in item.Product.Product.Images)
                    {
                        image.FileName = $"http://localhost:8080/contents/Products/{image.FileName}";
                    }
                }
            }
            return Ok(new
            {
                data = items
            });
        }

        [HttpPost("/cart")]
        public async Task<IActionResult> AddCartItems([FromBody] CartModel cartModel)
        {
            if (cartModel.Id == null)
            {
                return NotFound(new { message = "Không tồn tại product" });
            }
            ProductDetails? product = await _dbContext.ProductDetails.Include(p => p.Product).ThenInclude(p => p.Images).FirstOrDefaultAsync(p => p.Id == cartModel.Id);

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

        [HttpDelete("/cart/{id}")]
        public IActionResult DeleteCartItems(int id)
        {
            try
            {
                var cartItems = _cartService.GetItems();
                var item = cartItems.FirstOrDefault(c => c.Product.Id == id);
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

        [HttpPut("/cart/{id}")]
        public IActionResult UpdateCart(int id, [FromBody] CartModel cartModel)
        {
            var items = _cartService.GetItems();
            var item = items.FirstOrDefault(c => c.Product.Id == id);
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

        [HttpPost("/cart/new/{id}")]
        //id của user
        public async Task<IActionResult> NewCart(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy user để lấy orders" });
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
                    ShippingAddress = "N/A",
                    TotalPrice = totalMoney,
                };
                await _dbContext.Orders.AddAsync(newOrder);

                foreach (var item in items)
                {
                    if (item.Quantity > item.Product.StockQuantity)
                    {
                        return BadRequest(new { message = "Số lượng mua lớn hơn số lượng tồn kho" });
                    }
                    await _dbContext.OrderDetails.AddAsync(new OrderDetails()
                    {
                        Order = newOrder,
                        ProductDetailsId = item.Product.Id,
                        Quantity = item.Quantity
                    });
                    item.Product.StockQuantity -= item.Quantity;
                }
                _cartService.ClearCart();
                await _dbContext.SaveChangesAsync();
                return Ok(new { message = "Mua hàng thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
