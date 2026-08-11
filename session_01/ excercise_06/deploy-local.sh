#!/bin/bash

# ==========================================
# CẤU HÌNH MÀU SẮC (ANSI Color Codes)
# ==========================================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Cấu hình biến môi trường
APP_DIR="/opt/quickbite/user-service"
JAR_DEST="$APP_DIR/user-service-0.0.1.jar"
LOG_FILE="$APP_DIR/app.log"
# (Lưu ý: Bạn có thể cần điều chỉnh đường dẫn file JAR build ra dưới đây cho khớp với tên file thực tế của project)
BUILD_JAR_PATH="build/libs/session01-restful-0.0.1-SNAPSHOT.jar"

echo -e "${CYAN}=================================================${NC}"
echo -e "${CYAN} BẮT ĐẦU QUÁ TRÌNH TỰ ĐỘNG DEPLOY (deploy-local.sh) ${NC}"
echo -e "${CYAN}=================================================${NC}"

# ------------------------------------------
# BƯỚC 1: Biên dịch mã nguồn (Fail-fast)
# ------------------------------------------
echo -e "\n${YELLOW}[Bước 1] Biên dịch mã nguồn (Build & Test)...${NC}"
cd /home/thevinh19/demo/IOC-PTHB251125-BE103-Session02-RestfulAPI/
./gradlew clean bootJar

# Nguyên tắc Fail-fast: Kiểm tra exit code ($?)
if [ $? -ne 0 ]; then
    echo -e "${RED}[LỖI FATAL] Quá trình Build thất bại! Kịch bản dừng lại ngay lập tức.${NC}"
    exit 1
fi
echo -e "${GREEN}=> Biên dịch mã nguồn thành công!${NC}"

# ------------------------------------------
# BƯỚC 2: Chuẩn bị hạ tầng thư mục
# ------------------------------------------
echo -e "\n${YELLOW}[Bước 2] Kiểm tra và chuẩn bị hạ tầng thư mục...${NC}"
if [ ! -d "$APP_DIR" ]; then
    echo "Thư mục $APP_DIR chưa tồn tại. Đang tiến hành tạo mới..."
    sudo mkdir -p "$APP_DIR"
fi
# Phân quyền ownership cho thư mục
sudo chown quickbite:quickbite "$APP_DIR"
echo -e "${GREEN}=> Hạ tầng thư mục đã sẵn sàng.${NC}"

# ------------------------------------------
# BƯỚC 3: Sao chép ứng dụng
# ------------------------------------------
echo -e "\n${YELLOW}[Bước 3] Dừng tiến trình cũ và sao chép mã nguồn...${NC}"

# 3.1 Tìm và tắt tiến trình cũ đang chạy trên cổng 8080 (nếu có)
OLD_PID=$(sudo ss -tulpn | grep ':9999' | grep -oP 'pid=\K\d+')
if [ ! -z "$OLD_PID" ]; then
    echo "Phát hiện dịch vụ cũ đang chạy (PID: $OLD_PID). Đang dọn dẹp giải phóng cổng..."
    sudo kill -9 $OLD_PID
    sleep 2 # Đợi hệ thống nhả cổng mạng
fi

# 3.2 Sao chép file JAR mới và cấp quyền
if [ -f "$BUILD_JAR_PATH" ]; then
    sudo cp "$BUILD_JAR_PATH" "$JAR_DEST"
    sudo chown quickbite:quickbite "$JAR_DEST"
    echo -e "${GREEN}=> Sao chép ứng dụng và cấp quyền thành công.${NC}"
else
    echo -e "${RED}[LỖI] Không tìm thấy file JAR tại $BUILD_JAR_PATH.${NC}"
    exit 1
fi

# ------------------------------------------
# BƯỚC 4: Khởi động dịch vụ
# ------------------------------------------
echo -e "\n${YELLOW}[Bước 4] Khởi động ứng dụng Spring Boot...${NC}"
# Chạy dưới quyền user quickbite. 
# GHI CHÚ QUAN TRỌNG: Để Bước 5 có log mà trích xuất, luồng log thay vì chuyển vào /dev/null (lỗ đen) sẽ được ghi vào file $LOG_FILE.
sudo -u quickbite bash -c "nohup java -jar $JAR_DEST > $LOG_FILE 2>&1 &"
echo -e "${GREEN}=> Đã gửi lệnh khởi động ứng dụng chạy ngầm.${NC}"

# ------------------------------------------
# BƯỚC 5: Smoke Test
# ------------------------------------------
echo -e "\n${YELLOW}[Bước 5] Smoke Test: Đợi 20 giây để JVM khởi tạo...${NC}"
sleep 20

# Dùng lệnh ss để kiểm tra cổng 8080 có đang trạng thái LISTEN hay không
if sudo ss -tulpn | grep -q ":9999"; then
    echo -e "\n${GREEN}=======================================${NC}"
    echo -e "${GREEN}      DEPLOYS DỊCH VỤ THÀNH CÔNG!      ${NC}"
    echo -e "${GREEN}=======================================${NC}"
else
    echo -e "\n${RED}[LỖI] Dịch vụ khởi động thất bại (cổng 8080 chưa mở).${NC}"
    echo -e "${YELLOW}--- [DEBUG] 30 DÒNG LOG CUỐI CÙNG TỪ FILE LOG ---${NC}"
    
    # Trích xuất 30 dòng cuối từ file log để hỗ trợ debug
    if [ -f "$LOG_FILE" ]; then
         sudo tail -n 30 "$LOG_FILE"
    else
         echo "Chưa tạo được file log để hiển thị."
    fi
    exit 1 # Báo lỗi cho quy trình CI/CD (nếu có)
fi
