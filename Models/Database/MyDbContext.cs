using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WDProject.Models.Product;

namespace WDProject.Models.Database
{
    public class MyDbContext : IdentityDbContext
    {
        public DbSet<Categories> Categories { get; set; }   
        public DbSet<Order> Order { get; set; } 
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
        }
    }
}
