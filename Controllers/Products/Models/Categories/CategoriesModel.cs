using WDProject.Models.Product;

namespace WDProject.Areas.Product.Models.Category
{
    public class CategoriesModel
    {
        public List<Categories>? Categories { get; set; }
        public int totalCategories { get; set; }
        public int countPages { get; set; }
        public int ITEMS_PER_PAGE { get; set; } = 6;
        public int currentPage { get; set; }
    }
}
