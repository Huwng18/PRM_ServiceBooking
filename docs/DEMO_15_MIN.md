# Kịch bản demo Hẹnio — 15 phút

Chuẩn bị: emulator Android đã khởi động; chạy app debug. Dùng email demo riêng,
không dùng tài khoản thật. Chọn ngày mai để demo không phụ thuộc giờ hiện tại.
Không xóa database trước khi trình bày persistence. Chuẩn bị log và ảnh từ lần chạy thật.

| Thời gian | Thao tác và nội dung trình bày |
| --- | --- |
| 0:00–1:00 | Giới thiệu vấn đề đặt lịch, prototype PRM393; giới hạn dữ liệu demo và lưu trên thiết bị. |
| 1:00–2:30 | Giải thích UI → Provider → BookingRepository → SQLite; dịch vụ mẫu và SharedPreferences. |
| 2:30–4:00 | Đăng nhập demo; tìm “cat toc”; kết hợp danh mục/giá; đổi thứ tự giá; thử không có kết quả rồi xóa lọc. |
| 4:00–5:00 | Mở chi tiết, lưu yêu thích; quay về chứng minh bộ lọc còn; mở tab Yêu thích và kiểm tra đồng bộ trái tim. |
| 5:00–7:30 | Đặt lịch ngày mai 10:00; giải thích giờ mờ, thời lượng kết thúc trước 18:00; nhập ghi chú; xác nhận, xem màn thành công. |
| 7:30–9:30 | Mở Lịch hẹn, xem chi tiết; đổi sang 11:00; chỉ ra booking vẫn giữ ID và số lịch không tăng. Thử bỏ thao tác đổi lịch để chứng minh lịch cũ giữ nguyên. |
| 9:30–10:30 | Mở Thông báo từ Tài khoản: nhắc lịch mới ở 11:00. Chạm vào để mở booking; hủy với hộp thoại, kiểm tra tab Đã hủy và danh sách nhắc lịch rỗng. |
| 10:30–11:30 | Từ booking hủy chọn Đặt lại, chọn giờ mới rồi xác nhận; booking mới có ID mới. |
| 11:30–13:00 | Sửa tên; đóng/mở app, kiểm tra phiên, tên, yêu thích và lịch. Đăng xuất rồi dùng email khác: không thấy lịch/email trước. Đăng nhập lại email đầu và kiểm tra dữ liệu còn. |
| 13:00–14:30 | Trình bày kết quả unit/widget/integration tests: biên 18:00, overlap, đổi lịch bỏ qua chính nó, SQLite v1 và reopen, màn 320dp/chữ 200%, lỗi lưu và chặn gửi lặp. |
| 14:30–15:00 | Nêu giới hạn thực tế: mock auth, local storage, chưa có lịch nhà cung cấp/thanh toán/push; hướng phát triển tiếp theo. |

Nếu trình bày lỗi trùng lịch, chọn cùng dịch vụ cùng email vào khoảng giao nhau với
lịch còn hiệu lực. Lịch đã hủy không gây trùng. Không gọi lịch đã qua là “Hoàn thành”.
Chỉ trình bày kết quả test/build đã có log, không dùng ảnh hoặc số liệu giả.
