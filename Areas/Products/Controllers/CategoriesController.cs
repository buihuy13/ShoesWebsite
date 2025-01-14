using Microsoft.AspNetCore.Mvc;

namespace WDProject.Areas.Products.Controllers
{
    public class CategoriesController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
