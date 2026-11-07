# Kiểm chứng Hẹnio — 07/11/2026

Môi trường: Windows, Flutter 3.47.9 / Dart 3.13.7, emulator
`ServiceBooking_API_36` (`emulator-5554`, Android API 36, 1080×2400).
Các lệnh Flutter chạy từ junction ASCII `C:\Users\HUNG\develop\prm-servicebooking`.

## Kết quả thực tế

| Lệnh/kiểm tra | Kết quả |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test integration_test test_driver` | 35 files, 0 changed |
| `flutter analyze --no-pub` | No issues found |
| `flutter test --no-pub` | 22 tests passed |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test_android.ps1` | Hai kịch bản Android integration pass; driver báo All tests passed |
| `flutter build apk --debug` | Build thành công, APK app bình thường |
| APK bình thường: đăng nhập → đặt lịch ngày mai 10:00 → force-stop → mở lại → xem Lịch hẹn | Phiên và booking khôi phục; đã kiểm tra cây UI mới và chụp ảnh thật |
| Chạy script QA khi app chính đã có dữ liệu | App chính còn được cài, marker dữ liệu còn, SHA-256 SQLite không đổi |

Logs local: `format.log`, `analyze.log`, `flutter-test.log`,
`android-integration.log`, `build-debug.log`, `runtime-smoke.log` trong thư mục này.
Log thô không được commit; kết quả trên được ghi từ các lần chạy thật.

## Nội dung đã kiểm tra

- Tìm có/không dấu, hoa/thường, nhiều từ; kết hợp danh mục và giá, thứ tự giá;
  giữ tìm kiếm khi quay về từ chi tiết.
- Yêu thích đồng bộ giữa chi tiết/danh sách, lưu lại và cách ly theo email.
- Đăng nhập, khôi phục phiên/tên; không lưu mật khẩu; email khác không thấy lịch cũ.
- Giờ quá khứ/đúng hiện tại, mở cửa 08:00, kết thúc đúng 18:00, quá 18:00,
  dịch vụ 90 phút, giao nhau và hai khoảng tiếp giáp.
- Lịch hủy/email khác/dịch vụ khác không gây trùng; đổi lịch bỏ qua chính ID.
- Kiểm tra lại quy tắc trong transaction SQLite; hai yêu cầu trùng giờ đồng thời
  chỉ một yêu cầu thành công. Từ chối đổi/hủy lịch quá khứ hoặc sai chủ sở hữu.
- Đổi lịch giữ ID/số bản ghi; thoát form đổi lịch không thay đổi booking;
  hủy có xác nhận; đặt lại tạo ID mới.
- Nhắc lịch đổi giờ theo booking và biến mất khi hủy; chạm mở đúng chi tiết.
- Đọc database schema v1 đã có bản ghi; đóng/mở database vẫn còn dữ liệu.
  Schema giữ nguyên version 1, không có migration hay xóa database sản phẩm.
- Lỗi ghi không làm mất ghi chú/lịch cũ; chặn gửi lặp khi đang lưu.
- Layout 320×640 và 430×932; cỡ chữ 100% và 200%; bàn phím ở đăng nhập,
  ghi chú và dialog sửa tên; danh sách 24 lịch, trạng thái rỗng.
- Nút banner vẫn cuộn được tới dịch vụ khi màn nhỏ/chữ lớn; không có overflow
  hoặc exception trong các widget tests trên.

## APK và ảnh

- APK chính: `build/app/outputs/flutter-apk/app-debug.apk`.
- Bản sao APK chính: `build/app/outputs/flutter-apk/henio-debug.apk`.
- APK QA riêng: `build/app/outputs/flutter-apk/henio-qa-debug.apk` (không dùng để demo app chính).
- APK chính: 159,661,157 bytes; SHA-256:
  `D1ACF2562D1819E6A0780B7618E7E6A168D0497E512B9C61018F8E53F0319986`.
- 11 ảnh thật trong `docs/screenshots/henio-*.png`: đăng nhập, khám phá,
  chi tiết, đặt lịch, thành công, lịch hẹn, tài khoản, nhắc lịch, đã hủy,
  yêu thích và app sau khi mở lại.

## Thay đổi quan trọng

- `lib/theme/app_theme.dart`, `lib/widgets/`: màu/typography, components và ảnh offline.
- `lib/screens/`: làm lại toàn bộ màn hình, thêm Yêu thích, Chi tiết lịch,
  Tài khoản, Nhắc lịch và Về ứng dụng.
- `lib/providers/`: navigation, yêu thích theo email, tên hiển thị,
  mutation lịch chỉ cập nhật state sau khi ghi thành công.
- `lib/domain/booking_rules.dart`, `lib/data/booking_repository.dart`:
  kiểm tra nghiệp vụ và ghi từng booking bằng transaction, giữ schema cũ.
- `test/`, `integration_test/`, `test_driver/`, `scripts/test_android.ps1`:
  kiểm tra UI/nghiệp vụ/SQLite và runner Android cách ly.
- `README.md`, `docs/UI_REDESIGN.md`, `docs/DEMO_15_MIN.md`, `docs/REPORT_GUIDE.md`:
  kiến trúc, nguồn dữ liệu, cách chạy/build và demo.

## Sự cố kiểm thử và giới hạn

Các lần chạy đầu dùng `flutter drive` mặc định trên package chính của emulator.
Flutter driver tự gỡ package sau test, nên dữ liệu demo cũ trên emulator có thể
đã bị xóa. Không kiểm tra hay tác động điện thoại vật lý. Đây là tác động của
runner trên emulator; schema và logic ứng dụng giữ tương thích dữ liệu v1.

Đã sửa quy trình: target integration build package `.qa`; script kiểm tra manifest,
truyền APK QA dựng sẵn và `--keep-app-running`, rồi chỉ force-stop process QA.
Đã kiểm chứng app chính cùng marker và hash database còn nguyên sau lần chạy script.
Các lần sau **dùng script**, không gọi driver trực tiếp với cấu hình mặc định.

iOS, build release và ký phát hành chưa kiểm chứng. App vẫn là prototype local:
mock auth, không có backend, đồng bộ thiết bị, lịch nhà cung cấp, thanh toán thật
hay push notification. Báo cáo nhóm cần bổ sung thành viên và đóng góp thực tế.
