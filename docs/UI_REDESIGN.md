# Hẹnio — phạm vi cải tiến

## Khảo sát trước khi sửa

- Flutter Material 3; main khởi tạo AuthProvider và BookingProvider.
- Luồng UI → Provider/ChangeNotifier → BookingRepository → SQLite.
- SQLite v1: service_booking.db, bảng bookings (id, user_email, service_id, start_at, note, cancelled).
- SharedPreferences chỉ giữ email đăng nhập mô phỏng; không lưu mật khẩu.
- Danh mục 4 dịch vụ nằm trong demo_services.dart; không có API/backend.
- Baseline: flutter analyze không có lỗi; flutter test: 5 tests pass.
- Không tìm thấy AGENTS.md trong dự án.

## Vấn đề và phạm vi

Banner/icon lớn, chỉ có 3 tab; thiếu tìm không dấu, lọc giá, yêu thích, đổi lịch,
phân nhóm lịch, tên hiển thị và nhắc lịch trong app. Quy tắc booking mới chỉ kiểm
tra ở Provider; cần kiểm tra lại trước khi ghi SQLite và tuần tự hóa mutation.

Sửa theme, widgets, screens, providers, repository, models và tests. Thêm tiện ích
tìm kiếm, trạng thái UI, yêu thích local theo email. Giữ schema SQLite v1 và mọi
booking cũ; không thêm backend, auth thật, thanh toán hoặc push notification.

## Tham chiếu

UI: https://henio-service-mobile.inspiringbrownie.chatgpt.site/
Ảnh chụp được đọc qua Sites: nền kem, chữ xanh đậm, banner thiên nhiên, ảnh dịch vụ,
brand hẹnio và điều hướng Khám phá / Lịch hẹn / Yêu thích / Tài khoản.
Chuyển bố cục thành Flutter mobile; giữ dữ liệu nghiệp vụ hiện có, không dùng
đánh giá, giảm giá hoặc thông tin nhà cung cấp giả.

Ảnh Unsplash đóng gói offline, chỉ minh họa: photo-1441974231531-c6227db76b6e (rừng),
photo-1562322140-8baeececf3df (tóc), photo-1581578731548-c64695cc6952 (vệ sinh),
photo-1496181133206-80ce9b88a853 (laptop), photo-1434030216411-0b793f4b4173 (học tập).
