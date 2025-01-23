using Bogus;
using Microsoft.EntityFrameworkCore.Migrations;
using WDProject.Models.Product;

#nullable disable

namespace WDProject.Migrations
{
    /// <inheritdoc />
    public partial class fakedata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            Randomizer.Seed = new Random(8675309);
            var fake = new Faker<Products>();

            fake.RuleFor(p => p.Name, f => f.Lorem.Sentence(5, 15));
            fake.RuleFor(p => p.Description, f => f.Lorem.Sentence(5, 15));
            fake.RuleFor(p => p.Price, f => f.Random.Decimal(1000000,5000000));
            fake.RuleFor(p => p.Brand, f => "Adidas");

            for (int i = 0;i < 100; i++)
            {
                Products product = fake.Generate();
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
