#!/bin/bash

# Định nghĩa mã màu để in thông báo
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "--- GIAI ĐOẠN 1: Dọn dẹp tài nguyên (Clean up) ---"
# Kiểm tra xem container quickbite-db có tồn tại không (kể cả đang chạy hay đã dừng)
if [ "$(docker ps -aq -f name=quickbite-db)" ]; then
    echo "Phát hiện container quickbite-db cũ. Đang tiến hành xóa..."
    docker stop quickbite-db > /dev/null 2>&1
    docker rm quickbite-db > /dev/null 2>&1
    echo "Dọn dẹp thành công."
else
    echo "Không có container quickbite-db nào cần dọn dẹp."
fi

echo ""
echo "--- GIAI ĐOẠN 2: Kiểm soát cổng mạng (Port Check) ---"
# Sử dụng tính năng tích hợp của bash để kiểm tra port 5432 trên localhost
if (echo > /dev/tcp/localhost/5432) 2>/dev/null; then
    echo -e "${RED}LỖI: Cổng 5432 đang bị chiếm dụng trên máy host!${NC}"
    exit 1
else
    echo "Cổng 5432 đang trống, sẵn sàng sử dụng."
fi

echo ""
echo "--- GIAI ĐOẠN 3: Khởi tạo Database ---"
# Chạy container PostgreSQL mới ngầm (-d)
docker run -d \
  --name quickbite-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=12345678 \
  postgres:15-alpine

echo ""
echo "--- GIAI ĐOẠN 4: Kiểm thử độ sẵn sàng (Smoke Test) ---"
echo "Đang chờ 5 giây để Database khởi động..."
sleep 5

# Thăm dò bằng lệnh pg_isready
docker exec quickbite-db pg_isready -U postgres > /dev/null 2>&1
EXIT_CODE=$?

# Đánh giá kết quả exit code
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}DATABASE STAGING KHỞI TẠO THÀNH CÔNG!${NC}"
    exit 0
else
    echo -e "${RED}KHỞI TẠO THẤT BẠI! Lỗi xảy ra trong quá trình chạy container.${NC}"
    echo -e "${RED}Dưới đây là 20 dòng log cuối cùng phục vụ công tác gỡ lỗi:${NC}"
    echo "------------------------------------------------------"
    docker logs --tail 20 quickbite-db
    echo "------------------------------------------------------"
    exit 1
fi
