
namespace WDProject.Areas.Products.Models.Products
{
    public class CreateProductsModel : WDProject.Models.Product.Products
    {
        public List<int>? CategoryIds { get; set; }
    }
}
