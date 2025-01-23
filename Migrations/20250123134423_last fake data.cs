using Bogus;
using Microsoft.EntityFrameworkCore.Migrations;
using WDProject.Models.Product;

#nullable disable

namespace WDProject.Migrations
{
    /// <inheritdoc />
    public partial class lastfakedata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            var fakeImage = new Faker<ProductImage>();
            fakeImage.RuleFor(p => p.ProductId, f => f.Random.Int(8, 97));
            fakeImage.RuleFor(p => p.FileName, f => f.Random.ArrayElement(new[] { "jordan.jpg", "jordan1.jpg", "superstar.jpg", "superstar1.jpg", "r5io0spr.jpg" }));

            for (int i = 0; i < 100; i++)
            {
                ProductImage product = fakeImage.Generate();
                migrationBuilder.InsertData(
                    table: "ProductImage",
                    columns: new[] { "ProductId", "FileName" },
                    values: new object[]
                    {
                        product.ProductId,
                        product.FileName
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
