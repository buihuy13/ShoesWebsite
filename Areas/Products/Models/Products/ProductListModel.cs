using WDProject.Models.Product;

namespace WDProject.Areas.Product.Models.Product
{
    public class ProductListModel
    {
        public int totalProducts { get; set; }
        public int countPages { get; set; }
        public int ITEMS_PER_PAGE { get; set; } = 6;
        public int currentPage { get; set; }
        public List<Products>? ProductModels { get; set; }
    }
}
