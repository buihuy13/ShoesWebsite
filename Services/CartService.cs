
using Newtonsoft.Json;
using WDProject.Models.CartModel;
using WDProject.Models.Product;

namespace WDProject.Services
{
    public class CartService
    {
        private readonly IHttpContextAccessor _httpcontext;
        private readonly ILogger _logger;
        private const string CARTKEY = "Cart";
        private readonly HttpContext _context;
        public CartService(IHttpContextAccessor httpcontext, ILogger<CartService> logger)
        {
            _httpcontext = httpcontext;
            _context = httpcontext.HttpContext;
            _logger = logger;
        }

        //Lấy object từ trong session
        public List<CartItem> GetItems()
        {
            var session = _context.Session;
            string? jsonCart = session.GetString(CARTKEY);
            if (string.IsNullOrEmpty(jsonCart))
            {
                return JsonConvert.DeserializeObject<List<CartItem>>(jsonCart);
            }
            return new List<CartItem>();
        }
        //Xóa thông tin session
        public void ClearCart()
        {
            var session = _context.Session;
            session.Remove(CARTKEY);
        }
        //Lưu object vào trong session
        public void SaveCart(List<CartItem> items)
        {
            var session = _context.Session;
            session.SetString(CARTKEY, JsonConvert.SerializeObject(items));
        }
    }
}
