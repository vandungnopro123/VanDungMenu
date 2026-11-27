VDUNGZKeyGate - Theos source project

Dự án này là MÃ NGUỒN để build tweak dylib arm64 cho iOS 15+ bằng Theos.
Đây CHƯA PHẢI file dylib đã biên dịch và chưa được kiểm thử trên thiết bị thật.

Bundle mục tiêu: com.vdungzpr.ffvn.kernel
API: https://svkeyvdung.shopaccvt.site/api/verify.php
App ID: vdungzproject

Build trên máy đã cài Theos và iOS SDK:
  make package

Sản phẩm sau khi build thường nằm trong .theos/obj hoặc thư mục packages tùy cấu hình Theos.

Lưu ý quan trọng:
- Dylib hiện hiển thị hộp thoại nhập key và gửi POST xác thực server.
- Key hợp lệ được lưu cục bộ và không hỏi lại ở các lần mở tiếp theo.
- Bản mẫu này xác thực lúc kích hoạt lần đầu; chưa kiểm tra lại hạn key khi mở app sau đó.
- Chưa có khả năng xác nhận điểm móc START/STOP của binary gốc. Không tuyên bố đã khóa riêng START/STOP.
- Tương thích nạp dylib còn phụ thuộc cách đóng gói/inject/sign bằng TrollStore và cấu trúc app.
- Hãy giữ bản TIPA gốc để khôi phục nếu app gặp lỗi.
