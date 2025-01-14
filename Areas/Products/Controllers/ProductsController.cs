using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using WDProject.Areas.Products.Models.Products;
using WDProject.Data;
using WDProject.Models.Database;
using WDProject.Models.Product;

namespace WDProject.Areas.Product.Controllers
{
    [Area("Products")]
    [Route("/Products/[action]")]
    [Authorize(Roles = RoleName.admin)]
    public class ProductsController : Controller
    {
        private readonly MyDbContext _dbcontext;
        private readonly ILogger<ProductsController> _logger;
     
        public ProductsController(MyDbContext dbcontext, ILogger<ProductsController> logger)
        {
            _dbcontext = dbcontext;
            _logger = logger;
        }

        //Chưa viết
        public IActionResult Index()
        {
            return View();
        }

        //Ổn rồi
        [HttpGet]
        public async Task<IActionResult> GetProduct(int? id)
        {
            if (id == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }

            var product = await _dbcontext.Products.FirstOrDefaultAsync(p => p.Id == id);
            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }
            return Ok(new
            {
                message = "Tìm thấy thông tin giày",
                data = JsonConvert.SerializeObject(product)
            });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(CreateProductsModel model)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(e => e.Errors);
                foreach (var error in errors)
                {
                    _logger.LogError(error.ErrorMessage);
                    ModelState.AddModelError(string.Empty, error.ErrorMessage);
                }
                return BadRequest(new { message = "Lỗi khi tạo giày mới" });
            }

            try
            {
                await _dbcontext.AddAsync(model);
                if (model.CategoryIds != null)
                {
                    foreach (var cateId in model.CategoryIds)
                    {
                        await _dbcontext.AddAsync(new ProductsCategories()
                        {
                            ProductId = model.Id,
                            CategoryId = cateId
                        });
                    }
                }
                await _dbcontext.SaveChangesAsync();
                _logger.LogInformation("Tạo mới giày thành công");
                return Ok(new { message = "Tạo mới giày thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = ex.Message });
            }
        }

        //Ổn rồi
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int? id)
        {
            if (id == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }

            var product = await _dbcontext.Products.FirstOrDefaultAsync(p => p.Id == id);
            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }
            try
            {
                _dbcontext.Remove(product);
                await _dbcontext.SaveChangesAsync();
                _logger.LogInformation("Xóa giày thành công");
                return Ok(new { message = "Xóa giày thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
