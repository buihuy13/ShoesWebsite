using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WDProject.Areas.Product.Models.Product;
using WDProject.Data;
using WDProject.Models.Database;
using WDProject.Models.Product;

namespace WDProject.Areas.Product.Controllers
{
    [Area("Products")]
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

        //Đã ổn
        [HttpGet("/products")]
        [AllowAnonymous]
        public async Task<IActionResult> IndexAsync(SortModel sort,[FromQuery(Name = "p")] int currentPage)
        {
            try
            {
                var model = new ProductListModel();
                model.currentPage = currentPage;

                IQueryable<Products>? qr = _dbcontext.Products.Include(p => p.Images)
                                                              .Include(p => p.ProductsCategories).ThenInclude(p => p.Category);

                int totalProduct = await qr.CountAsync();

                if (sort != null)
                {
                    if (totalProduct > 0) 
                    {
                        if (!string.IsNullOrEmpty(sort.Name))
                        {
                            qr = qr.Where(p => p.Name.ToLower().Contains(sort.Name.ToLower()));
                        }

                        if (sort.CategoryId != null)
                        {
                            qr = qr.Where(qr => qr.ProductsCategories.Where(pc => pc.CategoryId == sort.CategoryId).Any());
                        }

                        if (!string.IsNullOrEmpty(sort.Brand))
                        {
                            var list = sort.Brand.Split(',');
                            var brandList = list.Select(b => b.ToLower());
                            qr = qr.Where(q => brandList.Contains(q.Brand.ToLower()));
                        }

                        if (!string.IsNullOrEmpty(sort.Order))
                        {
                            if (sort.Order == "ascending")
                            {
                                qr = qr.OrderBy(p => p.Price);
                            }
                            if (sort.Order == "descending")
                            {
                                qr = qr.OrderBy(p => p.Price);
                            }
                        }
                    }
                }

                model.totalProducts = totalProduct;
                model.countPages = (int)Math.Ceiling((double)model.totalProducts / model.ITEMS_PER_PAGE);

                if (model.currentPage < 1)
                    model.currentPage = 1;
                if (model.currentPage > model.countPages)
                    model.currentPage = model.countPages;

                var qr1 = qr.Skip((model.currentPage - 1) * model.ITEMS_PER_PAGE)
                            .Take(model.ITEMS_PER_PAGE);

                model.ProductModels = await qr1.ToListAsync();
                foreach (var product in model.ProductModels)
                {
                    if (product.Images != null && product.Images.Count() > 0)
                    {
                        foreach (var image in product.Images)
                        {
                            image.FileName = $"http://localhost:8080/contents/Products/{image.FileName}";
                        }
                    }
                }
                var ProductList = model.ProductModels.Select(p => new
                {
                    Id = p.Id,
                    Name = p.Name,
                    Price = p.Price,
                    Images = p.Images.Select(i => i.FileName),
                    Brand = p.Brand,
                });
                return Ok(new
                {
                    data = ProductList,
                    CurrentPage = model.currentPage,
                    TotalPage = model.countPages
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("/products/{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetProduct(int? Id)
        {
            if (Id == null)
            {
                return NotFound(new { message = "không tìm thấy product" });
            }
            var product = await _dbcontext.Products.Include(p => p.Details)
                                              .Include(p => p.Images)
                                              .Include(p => p.ProductsCategories).ThenInclude(pc => pc.Category)
                                              .FirstOrDefaultAsync(p => p.Id == Id); 
            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }
            if (product.Images != null && product.Images.Count() > 0)
            {
                foreach (var image in product.Images)
                {
                    image.FileName = $"http://localhost:8080/contents/Products/{image.FileName}";
                }
            }
            return Ok(new
            {
                data = product
            });
        }

        [HttpPost("/products")]
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
                var product = new Products()
                {
                    Name = model.Name,
                    Description = model.Description,
                    Price = model.Price,
                    Brand = model.Brand
                };
                await _dbcontext.AddAsync(product);
                Console.WriteLine(model.Files.Count());
                if (model.Files != null && model.Files.Count() > 0)
                {
                    Console.WriteLine("Vao duoc file");
                    foreach (var NewFile in model.Files)
                    {
                        var file1 = Path.GetFileNameWithoutExtension(Path.GetRandomFileName()) + Path.GetExtension(NewFile.FileName);

                        var file = Path.Combine("Uploads", "Products", file1);

                        using var filestream = new FileStream(file, FileMode.Create);
                        await NewFile.CopyToAsync(filestream);

                        await _dbcontext.AddAsync(new ProductImage()
                        {
                            Product = product,
                            FileName = file1
                        });
                    }
                }

                if (model.Size != null && model.Quantity!= null && model.Size.Count() > 0 && model.Size.Count() == model.Quantity.Count())
                {
                    var productDetailsList = new List<ProductDetails>();
                    for (int i = 0; i < model.Size.Count(); i++)
                    {
                        productDetailsList.Add(new ProductDetails()
                        {
                            Product = product,
                            Size = model.Size[i],
                            StockQuantity = model.Quantity[i]
                        });
                    }
                    await _dbcontext.AddRangeAsync(productDetailsList);
                }

                if (model.CategoryIds != null)
                {
                    foreach (var cateId in model.CategoryIds)
                    {
                        await _dbcontext.AddAsync(new ProductsCategories()
                        {
                            Product = product,
                            CategoryId = cateId
                        });
                    }
                }
                await _dbcontext.SaveChangesAsync();
                _logger.LogInformation("Tạo mới giày thành công");
                return StatusCode(201, new { message = "Tạo mới giày thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                return BadRequest(new { message = ex.Message });
            }
        }

        //Ổn rồi
        [HttpDelete("/products/{id}")]
        public async Task<IActionResult> DeleteConfirmed(int? id)
        {
            if (id == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }

            var product = await _dbcontext.Products.Include(p => p.Images).FirstOrDefaultAsync(p => p.Id == id);
            if (product == null)
            {
                return NotFound(new { message = "Không tìm thấy giày" });
            }
            try
            {
                if (product.Images != null && product.Images.Count() > 0)
                {
                    foreach (var productImage in product.Images)
                    {
                        var fileName = "Uploads/Products/" + productImage.FileName;
                        System.IO.File.Delete(fileName);
                    }
                }
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

        [HttpPut("/products/{id}")]
        public async Task<IActionResult> Update(CreateProductsModel model, int id)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { message = "Có data sai định dạng" });
            }
            try
            {
                var product = await _dbcontext.Products.Include(p => p.Images)
                                                     .Include(p => p.ProductsCategories).ThenInclude(p => p.Category)
                                                     .FirstOrDefaultAsync(p => p.Id == id);

                var oldCate = product.ProductsCategories.Select(p => p.CategoryId).ToList();
                var newCate = model.CategoryIds;
                var addNewCate = newCate.Where(c => !oldCate.Contains(c));
                var deleteCate = from productCate in product.ProductsCategories
                                 where !newCate.Contains(productCate.CategoryId)
                                 select productCate;

                _dbcontext.RemoveRange(deleteCate);

                foreach (var categoryId in addNewCate)
                {
                    await _dbcontext.AddAsync(new ProductsCategories()
                    {
                        ProductId = id,
                        CategoryId = categoryId,
                    });
                }
                product.Name = model.Name;
                product.Price = model.Price;
                product.Description = model.Description;
                product.Brand = model.Brand;
                await _dbcontext.SaveChangesAsync();
                return Ok(new { message = "Thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(new {message = ex.Message});
            }
        }
    }
}