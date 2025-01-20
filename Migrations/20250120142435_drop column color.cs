using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WDProject.Migrations
{
    /// <inheritdoc />
    public partial class dropcolumncolor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Color",
                table: "ProductDetails");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Color",
                table: "ProductDetails",
                type: "longtext",
                nullable: false);
        }
    }
}
