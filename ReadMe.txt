API Document: https://docs.google.com/document/d/1phZZyzUhdMAOYlu53GobjKZc_Qi8jof0tkM74DjckLs/edit?tab=t.0


B1: Tạo tài khoản admin
- Postman: http://localhost:8080/auth/register
+, Body cho register trong postman: 
{
    "Email" : "admin@gmail.com",
    "UserName": "admin",
    "Password": "admin123",
    "ConfirmPassword": "admin123"
}

*, Yêu cầu đúng tên và password để nhận được role admin