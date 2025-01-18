using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WDProject.Areas.Product.Models.ProductDetail;
using WDProject.Models.Database;
using WDProject.Models.Product;

namespace WDProject.Areas.Product.Controllers
{
    public class ProductDetailController : Controller
    {
        private readonly MyDbContext _dbcontext;
        private readonly ILogger<ProductDetailController> _logger;

        public ProductDetailController(MyDbContext dbcontext, ILogger<ProductDetailController> logger)
        {
            _dbcontext = dbcontext;
            _logger = logger;
        }
        [HttpGet("/productdetails/{id}")]
        public async Task<IActionResult> GetDetails(int id)
        {
            var product = await _dbcontext.Products.Include(p => p.Details)
                                                   .Include(p => p.Images)
                                                   .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy product" });
            }

            try
            {
                var response = new
                {
                    Name = product.Name,
                    Descritption = product.Description,
                    Price = product.Price,
                    Images = product.Images.Select(i => i.FileName),
                    Brand = product.Brand,
                    Details = product.Details
                };
                return Ok(new
                {
                    data = response
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new {message = ex.Message });
            }
        }
        //id của product
        [HttpPost("/productdetails/new/{id}")]
        public async Task<IActionResult> AddDetails(int id, [FromBody]CreateDetailModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new
                {
                    message = "Lỗi định dạng"
                });
            }
            var product = await _dbcontext.Products.Include(p => p.Details)
                                                   .Include(p => p.Images)
                                                   .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy product" });
            }

            try
            {
                var productDetail = new ProductDetails()
                {
                    ProductId = id,
                    Color = model.Color,
                    Size = model.Size,
                    StockQuantity = model.StockQuantity,
                };

                await _dbcontext.AddAsync(productDetail);
                await _dbcontext.SaveChangesAsync();
                return Ok(new { message = "Thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = "Thất bại" });
            }
        }
        [HttpPut("/productdetails/{id}")]
        public async Task<IActionResult> UpdateDetails(int id, [FromBody] CreateDetailModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new
                {
                    message = "Lỗi định dạng"
                });
            }
            var product = await _dbcontext.ProductDetails.FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy product" });
            }

            try
            {
                product.Color = model.Color;
                product.Size = model.Size;
                product.StockQuantity = model.StockQuantity;

                _dbcontext.Update(product);
                await _dbcontext.SaveChangesAsync();
                return Ok(new { message = "Thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = "Thất bại" });
            }
        }

        [HttpDelete("/productdetails/{id}")]
        public async Task<IActionResult> DeleteDetails(int id)
        {
            var product = await _dbcontext.ProductDetails.FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy product" });
            }

            try
            {
                _dbcontext.Remove(product);
                await _dbcontext.SaveChangesAsync();
                return Ok(new { message = "Thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = "Thất bại" });
            }
        }
    }
}
