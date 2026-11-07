# Hẹnio · Service Booking — PRM393

Ứng dụng Flutter đặt lịch dịch vụ trên Android, làm lại giao diện dựa trên
[bản mẫu Hẹnio](https://henio-service-mobile.inspiringbrownie.chatgpt.site/).
Nền kem, xanh ngọc, ảnh minh họa offline và bốn tab: Khám phá, Lịch hẹn, Yêu thích, Tài khoản.

## Chạy dự án

Cần Flutter SDK, Android SDK và Java phù hợp với Flutter/Gradle. Trên máy hiện tại
đã có junction giúp tránh lỗi công cụ với đường dẫn Unicode `Kì 8`:

```powershell
cd C:\Users\HUNG\develop\prm-servicebooking
flutter pub get
flutter doctor
flutter emulators --launch ServiceBooking_API_36
flutter devices
flutter run -d emulator-5554
```

Junction trỏ đến source gốc; sửa tại một trong hai đường dẫn đều tác động cùng dự án.
Trên máy khác, đặt source trong đường dẫn ASCII và dùng ID thiết bị từ `flutter devices`.
iOS cần macOS/Xcode và chưa được kiểm chứng trong đợt sửa này.

## Đăng nhập demo

Email mặc định `demo@example.com`, mật khẩu `123456`.
Có thể dùng email đúng định dạng bất kỳ và mật khẩu từ 6 ký tự. Đây là mock auth,
không kiểm tra tài khoản thật; không dùng thông tin đăng nhập thật. Mật khẩu không
được lưu vào SQLite, SharedPreferences hoặc log.

## Chức năng

- Khám phá 4 dịch vụ mẫu: tìm có dấu/không dấu, không phân biệt hoa thường,
  kết hợp danh mục và khoảng giá, sắp xếp giá tăng/giảm, xóa bộ lọc.
- Chi tiết dịch vụ với ảnh, mô tả, giá, thời lượng và thanh đặt lịch.
- Yêu thích đồng bộ giữa danh sách/chi tiết và lưu riêng theo email.
- Chọn nhanh 7 ngày, lịch đầy đủ, giờ cách nhau 30 phút, ghi chú tối đa 500 ký tự.
  Giờ bị khóa có giải thích; không mô phỏng chỗ trống của nhà cung cấp.
- Đặt lịch: chặn gửi lặp, hiển thị lỗi mà giữ thông tin nhập, màn thành công.
- Lịch hẹn: Sắp tới / Đã qua / Đã hủy, chi tiết và ghi chú, hủy có xác nhận,
  đổi lịch giữ ID, đặt lại tạo booking mới sau khi chọn giờ mới.
- Tài khoản: tên hiển thị có thể sửa, avatar chữ cái, số lịch/yêu thích/nhắc lịch thực tế.
- Nhắc lịch trong app lấy từ lịch sắp tới; đổi/hủy cập nhật nội dung ngay.
- Khôi phục phiên, tên, yêu thích và lịch hẹn; đăng xuất không xóa lịch.

## Kiến trúc và nguồn dữ liệu

```text
lib/screens + lib/widgets (Material 3)
    → lib/providers (Provider / ChangeNotifier)
    → lib/data/booking_repository.dart
    → SQLite trên thiết bị
```

`lib/domain/booking_rules.dart` chứa quy tắc dùng chung giữa UI chọn giờ và repository.
Repository kiểm tra lại dữ liệu trong transaction trước khi INSERT/UPDATE;
không xóa toàn bộ bảng để lưu snapshot. Provider chỉ cập nhật sau khi ghi thành công.

| Dữ liệu | Nguồn/lưu trữ |
| --- | --- |
| 4 dịch vụ, giá, thời lượng | `lib/data/demo_services.dart`, dữ liệu cố định |
| Lịch hẹn, ghi chú, trạng thái hủy | SQLite `service_booking.db` |
| Email phiên demo | SharedPreferences `service_booking_session_v1` |
| Tên hiển thị | SharedPreferences `service_booking_name_v1_<email>` |
| ID dịch vụ yêu thích | SharedPreferences `service_booking_favorites_v1_<email>` |
| Ảnh | `assets/images/`, chỉ minh họa, có fallback icon |

SQLite **giữ version 1 và schema cũ**, không cần migration; dữ liệu cũ được giữ nguyên.
Database nằm trong vùng dữ liệu riêng của ứng dụng, không nằm trong repository Git.

```sql
CREATE TABLE bookings (
  id TEXT PRIMARY KEY,
  user_email TEXT NOT NULL,
  service_id TEXT NOT NULL,
  start_at TEXT NOT NULL,
  note TEXT NOT NULL,
  cancelled INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_booking_user ON bookings(user_email);
```

Thời gian dùng local, lưu ISO 8601 như phiên bản trước. Lịch phải ở tương lai,
trọn thời lượng trong 08:00–18:00. Chỉ chặn trùng cùng email + cùng dịch vụ:
`newStart < existingEnd && newEnd > existingStart`. Lịch hủy không gây trùng;
đổi lịch bỏ qua chính ID đang sửa. Không cho đổi/hủy lịch đã qua.
“Sắp tới” được tính bằng `!cancelled && startAt > now`; lịch đã qua không được gọi là hoàn thành.

## Kiểm tra và build

```powershell
dart format lib test integration_test test_driver
flutter analyze
flutter test
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test_android.ps1
flutter build apk --debug
```

`integration_test` là dependency **chỉ dành cho kiểm thử** từ Flutter SDK, thêm để
kiểm chứng plugin SQLite và UI trên Android thật của emulator. Các dependency runtime
và kiến trúc hiện có được giữ nguyên.

Chạy integration tests bằng **`scripts/test_android.ps1`**. Script build và kiểm tra
package `com.example.service_booking_flutter.qa`, truyền đúng APK cho driver và dùng
`--keep-app-running` để tránh cơ chế tự gỡ app của `flutter drive`. Không chạy trực tiếp
driver với cấu hình mặc định trên app có dữ liệu cần giữ. Script chỉ dừng process QA
sau khi kiểm thử; app chính `com.example.service_booking_flutter` dùng sandbox riêng.
Trên điện thoại ARM64, truyền `-Device <id> -TargetPlatform android-arm64`.
Tests dùng database `henio_qa_*` riêng, kiểm tra
schema v1, dữ liệu cũ, transaction đồng thời, đổi/hủy, mở lại database và luồng UI.
Chỉ chạy một bộ kiểm thử thiết bị tại một thời điểm.
Driver lưu ảnh thật vào `docs/screenshots/henio-*.png`.

APK debug: `build/app/outputs/flutter-apk/app-debug.apk`.
Log kiểm tra/build: `docs/qa/*.log` (được giữ local, không commit log thô).
Kết quả thực tế: [docs/qa/VERIFICATION.md](docs/qa/VERIFICATION.md).

## Ảnh giao diện

[Đăng nhập](docs/screenshots/henio-login.png) ·
[Khám phá](docs/screenshots/henio-discovery.png) ·
[Chi tiết](docs/screenshots/henio-service-detail.png) ·
[Đặt lịch](docs/screenshots/henio-booking-form.png) ·
[Thành công](docs/screenshots/henio-booking-success.png) ·
[Lịch hẹn](docs/screenshots/henio-bookings.png) ·
[Yêu thích](docs/screenshots/henio-favorites.png) ·
[Tài khoản](docs/screenshots/henio-account.png) ·
[Nhắc lịch](docs/screenshots/henio-reminders.png) ·
[Sau khi mở lại app](docs/screenshots/henio-restart.png).

## Giới hạn

Không có backend, xác thực thật, đồng bộ thiết bị, lịch nhà cung cấp, thanh toán,
bản đồ, chat hay thông báo đẩy. Cách ly dữ liệu theo email phục vụ demo UI,
không phải cơ chế bảo mật tài khoản. Bản debug dùng application ID/signing của
prototype; chưa kiểm chứng build release hoặc ký phát hành.

Ảnh minh họa lấy từ Unsplash, mã ảnh ghi tại [UI_REDESIGN.md](docs/UI_REDESIGN.md).
[Kịch bản demo 15 phút](docs/DEMO_15_MIN.md) và [hướng dẫn báo cáo](docs/REPORT_GUIDE.md)
cần bổ sung tên thành viên, đóng góp và bằng chứng của nhóm trước khi nộp.
