using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using WDProject.Areas.Identity.Models.Admin;
using WDProject.Areas.Products.Models.Category;
using WDProject.Models.Database;
using WDProject.Models.Product;

namespace WDProject.Areas.Products.Controllers
{
    public class CategoriesController : Controller
    {
        private readonly MyDbContext _dbContext;
        private readonly ILogger<CategoriesController> _logger; 
        public CategoriesController(MyDbContext dbContext,ILogger<CategoriesController> logger)
        {
            _dbContext = dbContext;
            _logger = logger;
        }
        [HttpGet("/categories/getcategories")]
        public IActionResult Index([FromQuery(Name = "p")] int currentPage)
        {
            try
            {
                var model = new CategoriesModel();
                model.currentPage = currentPage;
                var categoryList = _dbContext.Categories.ToList();

                model.totalUsers = categoryList.Count;
                model.countPages = (int)Math.Ceiling((double)model.totalUsers / model.ITEMS_PER_PAGE);

                if (model.currentPage < 1)
                    model.currentPage = 1;
                if (model.currentPage > model.countPages)
                    model.currentPage = model.countPages;

                var qr = categoryList.Skip((model.currentPage - 1) * model.ITEMS_PER_PAGE).Take(model.ITEMS_PER_PAGE);
                model.Categories = qr.ToList();

                return Ok(new { data = JsonConvert.SerializeObject(model.Categories) });
            }
            catch (Exception ex)
            {
                _logger.LogInformation(ex.Message);
                return BadRequest("Không tạo ra list các categories được");
            }
        }

        [HttpPost("/categories/new")]
        public async Task<IActionResult> Create([FromBody] Models.Category.CreateModel model)
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

            try
            {
                await _dbContext.AddAsync(new Categories() { Name = model.Name, Description = model.Description });
                await _dbContext.SaveChangesAsync();
                return Ok(new { message = "Tạo mới 1 category thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogInformation(ex.Message);
                return BadRequest(new { message = "Không thể tạo mới 1 category" });
            }
        }

        [HttpDelete("/categories/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var category = _dbContext.Categories.ToList().FirstOrDefault(c => c.Id == id);
            if (category == null)
            {
                return NotFound(new { message = "Chưa truyền id vào" });
            }
            try
            {
                _dbContext.Categories.Remove(category);
                await _dbContext.SaveChangesAsync();
                return Ok(new {message = "Xóa category thành công"});
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new {message = ex.Message});  
            }
        }

        [HttpGet("/categories/{id}")]
        public IActionResult Details(int id)
        {
            var category = _dbContext.Categories.ToList().FirstOrDefault(c => c.Id == id);
            if (category == null)
            {
                return NotFound(new { message = "Chưa truyền id vào" });
            }
            return Ok(new {data = JsonConvert.SerializeObject(category)});  
        }

        [HttpPut("/categories/{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] Models.Category.CreateModel model)
        {
            var category = _dbContext.Categories.ToList().FirstOrDefault(c => c.Id == id);
            if (category == null)
            {
                return NotFound(new { message = "Chưa truyền id vào" });
            }
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
            try
            {
                category.Name = model.Name;
                category.Description = model.Description;
                _dbContext.Update(category);
                await _dbContext.SaveChangesAsync();
                return Ok(new { message = "Sửa thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
