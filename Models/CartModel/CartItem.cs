using System.ComponentModel.DataAnnotations;
using WDProject.Models.Product;

namespace WDProject.Models.CartModel
{
    public class CartItem
    {
        [Required]
        public int Quantity { get; set; }
        [Required]
        public ProductDetails Product {  get; set; }
    }
}
