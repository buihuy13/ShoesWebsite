I, Backend

1. Đăng ký, đăng nhập, xem chi tiết người dùng, chỉnh sửa người dùng, xóa người dùng
- Controller: /Areas/Identity/Controllers/AccountController
- Các Model đối với các trang này: /Areas/Identity/Models/Account/
- Chi tiết:

+, Trang Đăng ký (Register) (Sử dụng Model: /Areas/Identity/Models/Account/RegisterModel)
Post: Kiểm tra định dạng của các thông tin đăng ký xem đã phù hợp chưa, nếu chưa -> Báo lỗi và trả về 400 (Bad Request), Nếu trùng -> 409 (Conflict)

+, Trang đăng nhập (Login) (Sử dụng Model: /Areas/Identity/Models/Account/LoginModel)
Post: Kiểm tra định dạng và các thông tin đăng nhập đã phù hợp chưa. Nếu đăng nhập được thì đưa vào trang chủ, nếu chưa thì -> 401 (Unauthorized)

+, Đăng xuất (LogOut) 
Post: Đăng xuất tài khoản hiện tại và đưa lại về trang đăng nhập

+, Chỉnh sửa người dùng (Edit) (Sử dụng Model: /Areas/Identity/Models/Account/EditModel) **(Đang thiếu HomePage trả về)
Get: Trả về thông tin người dùng tương ứng với EditModel (Json) (Cần truyền Id vào trong route parameters)
Post: Chỉnh sửa người dùng có Id được truyền và những thông tin được sửa

+, Xem chi tiết người dùng (Details) 
Get: Trả về thông tin chi tiết của người dùng theo Json (Cần truyền Id vào trong route parameters) 

+, Xóa người dùng 
Get (Delete): Trả về thông tin chi tiết của người dùng theo Json (Cần truyền Id vào trong route parameters) 
Post (DeleteConfirmed): Xóa người dùng đang đăng nhập hiện tại 


2, Trang Admin (CRUD) (Tạo người dùng mới, Xem chi tiết 1 người dùng, Chỉnh sửa 1 người dùng, Xóa đi 1 người dùng)
- Controller: /Areas/Identity/Controllers/AdminController
- Các Model đối với các trang này: /Areas/Identity/Models/Admin/
- Chi tiết: 

+, Trang hiển thị tất cả người dùng (Index) (Sử dụng Model: /Areas/Identity/Models/Admin/UserModel) **Chưa xong
Get: Hiển thị tất cả người dùng và chia theo trang 

+, Trang thêm người dùng mới (Create) (Sử dụng Model: /Areas/Identity/Models/Admin/CreateModel)
Post: Thêm 1 người dùng mới

+, Xem chi tiết người dùng (Details) 
Get: Trả về thông tin chi tiết của người dùng theo Json (Cần truyền Id vào trong route parameters) 

+, Xóa người dùng 
Get (Delete): Trả về thông tin chi tiết của người dùng theo Json (Cần truyền Id vào trong route parameters) 
Post (DeleteConfirmed): Xóa người dùng đang đăng nhập hiện tại 




x, Các phần thêm
- Session: Hỗ trợ trang bán hàng (Lưu lại những đơn hàng đang mua nhưng bị thoát ra) 
 /Helpers/CartService

- FakeData: Fake user, admin và thiết lập các role (Init Data) 

- Đã làm JWT (đã config trong program.cs và tạo ra service cho jwt token ở trong Services/TokenService) 
(Đã làm cho login, logout, chỉ còn forgot password)

