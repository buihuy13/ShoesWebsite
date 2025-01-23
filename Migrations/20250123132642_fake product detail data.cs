using Bogus;
using Bogus.DataSets;
using Microsoft.EntityFrameworkCore.Migrations;
using WDProject.Models.Product;

#nullable disable

namespace WDProject.Migrations
{
    /// <inheritdoc />
    public partial class fakeproductdetaildata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            Randomizer.Seed = new Random(8675309);
            var fake = new Faker<ProductDetails>();

            fake.RuleFor(p => p.ProductId, f => f.Random.Int(8,97));
            fake.RuleFor(p => p.Size, f => f.Random.Int(35, 48));
            fake.RuleFor(p => p.StockQuantity, f => f.Random.Int(8, 200));

            for (int i = 0; i < 300; i++)
            {
                ProductDetails product = fake.Generate();
                migrationBuilder.InsertData(
                    table: "ProductDetails",
                    columns: new[] { "ProductId", "Size", "StockQuantity" },
                    values: new object[]
                    {
                        product.ProductId,
                        product.Size,
                        product.StockQuantity
                    }
                );
            }

            var fakeProduct = new Faker<Products>();

            fakeProduct.RuleFor(p => p.Name, f => f.Lorem.Sentence(5, 15));
            fakeProduct.RuleFor(p => p.Description, f => f.Lorem.Sentence(5, 15));
            fakeProduct.RuleFor(p => p.Price, f => f.Random.Decimal(1000000, 5000000));
            fakeProduct.RuleFor(p => p.Brand, f => f.Random.ArrayElement(new[] {"Puma", "Nike"}));

            for (int i = 0; i < 100; i++)
            {
                Products product = fakeProduct.Generate();
                migrationBuilder.InsertData(
                    table: "Products",
                    columns: new[] { "Name", "Description", "Price", "Brand" },
                    values: new object[]
                    {
                    product.Name,
                    product.Description,
                    product.Price,
                    product.Brand
                    }
                );
            }
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
