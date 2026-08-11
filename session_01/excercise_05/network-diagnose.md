# Báo cáo chẩn đoán lỗi mạng (Network Diagnostic Report)

## Tình huống 1: Khắc phục lỗi trùng cổng 8080
**Mục tiêu:** Tìm và tắt tiến trình đang chiếm dụng cổng 8080 để giải phóng cổng cho ứng dụng `user-service`.

**Các lệnh đã sử dụng:**
1. `sudo ss -tulpn | grep :8080`
   * **Mục đích:** Tìm kiếm các kết nối mạng đang lắng nghe trên cổng 8080 và lấy thông tin Process ID (PID) của tiến trình chiếm dụng.
2. `sudo kill -9 <PID>` (Ví dụ: `sudo kill -9 1234`)
   * **Mục đích:** Ép buộc (force kill) hệ điều hành dừng ngay lập tức tiến trình có mã PID tương ứng để giải phóng cổng 8080.

---

## Tình huống 2: Chẩn đoán lỗi kết nối Database PostgreSQL (IP 10.0.1.20)
**Mục tiêu:** Kiểm tra đường truyền và cổng dịch vụ để tìm nguyên nhân ứng dụng không thể kết nối tới cơ sở dữ liệu.

**Các lệnh đã sử dụng:**
1. `ping -c 4 10.0.1.20`
   * **Mục đích:** Kiểm tra kết nối mạng vật lý cơ bản từ máy chủ ứng dụng tới máy chủ Database.
   * **Kết quả chẩn đoán:** Báo lỗi `100% packet loss`. Máy chủ hiện không có kết nối mạng tới địa chỉ IP này.
2. `nc -zv 10.0.1.20 5432`
   * **Mục đích:** Thăm dò xem cổng dịch vụ 5432 của PostgreSQL có đang mở để nhận kết nối hay không.
   * **Kết quả chẩn đoán:** Báo lỗi `Connection timed out`. Do đường truyền mạng vật lý đã đứt (phát hiện từ lệnh ping), lệnh thăm dò cổng cũng thất bại vì quá thời gian chờ.
