using WDProject.Models.Product;

namespace WDProject.Models.CartModel
{
    public class CartItem
    {
        public int Quantity { get; set; }
        public Products Product {  get; set; }
    }
}
