using WDProject.Models.Product;

namespace WDProject.Areas.Products.Models.Category
{
    public class CategoriesModel
    {
        public List<Categories>? Categories { get; set; }
        public int totalUsers { get; set; }
        public int countPages { get; set; }
        public int ITEMS_PER_PAGE { get; set; } = 20;
        public int currentPage { get; set; }
    }
}
