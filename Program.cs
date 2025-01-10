using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using WDProject.Helpers;
using WDProject.Models.Database;
using WDProject.Models.Identity;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddRazorPages();

//Đăng ký database
builder.Services.AddDbContext<MyDbContext>(options =>
{
    var dbInfo = builder.Configuration.GetConnectionString("AppContext");
    options.UseMySQL(dbInfo);
});

//Kích hoạt sử dụng Options
builder.Services.AddOptions();

//Đăng ký dịch vụ cho Identity
builder.Services.AddIdentity<User, IdentityRole>()
                .AddEntityFrameworkStores<MyDbContext>()
                .AddDefaultTokenProviders();

//Đăng ký ủy quyền truy cập khi vào 1 trang
builder.Services.ConfigureApplicationCookie(options =>
{
    options.LoginPath = "/Identity/Account/Login";
    options.LogoutPath = "/Identity/Account/Logout";
    options.AccessDeniedPath = "/Identity/Account/AccessDenied";
});

//Configure cho đăng nhập, đăng ký
builder.Services.Configure<IdentityOptions>(options =>
{
    // Thiết lập Password
    options.Password.RequireDigit = false; // Không bắt phải có số
    options.Password.RequireLowercase = false; // Không bắt phải có chữ thường
    options.Password.RequireNonAlphanumeric = false; // Không bắt kí tự đặc biệt
    options.Password.RequireUppercase = false; // Không bắt buộc chữ in hoa
    options.Password.RequiredLength = 6; // Số kí tự tối thiểu của password
    options.Password.RequiredUniqueChars = 1; // Số kí tự riêng biệt

    // Cấu hình User.
    options.User.AllowedUserNameCharacters = // các kí tự cho phép trong tên của user
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
    options.User.RequireUniqueEmail = true;  // Email là duy nh?t và chưa được sử dụng

    // Cấu hình đăng nhập.
    options.SignIn.RequireConfirmedEmail = false;            // Cấu hình xác thực địa chỉ email (email không cần phải tồn tại)
    options.SignIn.RequireConfirmedPhoneNumber = false;     // Xác thực số điện thoại
    options.SignIn.RequireConfirmedAccount = true;     //Xác thực tài khoản sau khi đăng kí
});

builder.Services.AddDistributedMemoryCache();

//Config cho Session
builder.Services.AddSession(options =>
{
    options.Cookie.Name = "ShoesWebsite";
    options.IdleTimeout = TimeSpan.FromMinutes(2);
});

//Thêm cors, cho phép mọi trang đều call được api từ WDProject
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

//Đăng ký dịch vụ cho việc sử dụng session
builder.Services.AddTransient<CartService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseSession();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
