#!/bin/bash

# Định nghĩa đường dẫn file log
LOG_FILE="/opt/rikkei/deploy.log"

echo "=========================================" >> $LOG_FILE
echo "Bắt đầu triển khai lúc: $(date)" >> $LOG_FILE

# 1 & 2: Kiểm tra xem container có tồn tại không (bao gồm cả trạng thái đã dừng)
if docker ps -a --format '{{.Names}}' | grep -Eq "^rikkei-course-service$"; then
    echo "-> Phát hiện container rikkei-course-service cũ. Đang thực hiện dừng và xóa..." >> $LOG_FILE
    docker stop rikkei-course-service >> $LOG_FILE 2>&1
    docker rm rikkei-course-service >> $LOG_FILE 2>&1
    echo "-> Đã dọn dẹp container cũ thành công." >> $LOG_FILE
else
    echo "-> Không tìm thấy container cũ. Bỏ qua bước xóa." >> $LOG_FILE
fi

# 3: Khởi chạy lại container mới
echo "-> Đang khởi chạy container rikkei-course-service mới từ image nginxdemos/hello..." >> $LOG_FILE
docker run -d --name rikkei-course-service -p 8081:80 nginxdemos/hello >> $LOG_FILE 2>&1

echo "Triển khai hoàn tất lúc: $(date)" >> $LOG_FILE
echo "=========================================" >> $LOG_FILE


sudo nano /opt/rikkei/update-course-service.sh
sudo chmod +x /opt/rikkei/update-course-service.sh
su - rikkeilms
bash update-course-service.sh
bash update-course-service.sh
cat /opt/rikkei/deploy.log
