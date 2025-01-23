using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WDProject.Models.Identity;
using WDProject.Models.Product;

namespace WDProject.Models.Database
{
    public class MyDbContext : IdentityDbContext
    {
        public DbSet<Categories> Categories { get; set; } 
        public DbSet<ProductImage> ProductImage { get; set; }
        public DbSet<Order> Orders { get; set; } 
        public DbSet<OrderDetails> OrderDetails { get; set; }   
        public DbSet<ProductDetails> ProductDetails { get; set; }
        public DbSet<Products> Products { get; set; }
        public DbSet<ProductsCategories> ProductsCategories { get; set; }   
        public MyDbContext(DbContextOptions<MyDbContext> options) : base(options) { }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            base.OnConfiguring(optionsBuilder);
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            foreach (var entityType in builder.Model.GetEntityTypes())
            {
                var tableName = entityType.GetTableName();
                if (tableName != null && tableName.StartsWith("AspNet"))
                {
                    entityType.SetTableName(tableName.Substring(6));
                }
            }

            //Đảm bảo khi 1 product bị xóa thì productcategories có tham chiếu product đó cũng bị xóa
            builder.Entity<Products>()
                   .HasMany(p => p.ProductsCategories)
                   .WithOne(pc => pc.Product)
                   .HasForeignKey(pc => pc.ProductId)
                   .OnDelete(DeleteBehavior.Cascade);

            //Đảm bảo khi xóa 1 categories thì productcategories có tham chiếu categories đó cũng bị xóa
            builder.Entity<Categories>()
                   .HasMany(c => c.ProductsCategories)
                   .WithOne(pc => pc.Category)
                   .HasForeignKey(pc => pc.CategoryId)
                   .OnDelete(DeleteBehavior.Cascade);

            //Đảm bảo khi xóa 1 products thì productdetails có tham chiếu products đó cũng bị xóa
            builder.Entity<Products>()
                   .HasMany(p => p.Details)
                   .WithOne(pd => pd.Product)
                   .HasForeignKey(pd => pd.ProductId)
                   .OnDelete(DeleteBehavior.Cascade);

            //Đảm bảo khi xóa 1 user thì orders có tham chiếu user đó cũng bị xóa
            builder.Entity<User>()
                   .HasMany(u => u.Orders)
                   .WithOne(uo => uo.User)
                   .HasForeignKey(uo => uo.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            //Đảm bảo khi xóa 1 order thì orderDetails có tham chiếu order đó cũng bị xóa
            builder.Entity<Order>()
                   .HasMany(o => o.OrderDetails)
                   .WithOne(od => od.Order)
                   .HasForeignKey(od => od.OrderId)
                   .OnDelete(DeleteBehavior.Cascade);

            //Đảm bảo khi xóa 1 products thì productimages có tham chiếu products đó cũng bị xóa
            builder.Entity<Products>()
                   .HasMany(p => p.Images)
                   .WithOne(pi => pi.Product)
                   .HasForeignKey(pi => pi.ProductId)
                   .OnDelete(DeleteBehavior.Cascade);

            //Đảm bảo khi xóa 1 products thì orderdetails có tham chiếu products đó cũng bị xóa
            builder.Entity<ProductDetails>()
                   .HasMany(p => p.OrderDetails)
                   .WithOne(pd => pd.ProductDetails)
                   .HasForeignKey(pd => pd.ProductDetailsId)
                   .OnDelete(DeleteBehavior.Cascade);

        }
    }
}
