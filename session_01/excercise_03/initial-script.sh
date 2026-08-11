#!/bin/bash


sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y openjdk-17-jdk git curl

if ! getent group quickbite > /dev/null 2>&1; then
    sudo groupadd quickbite
    echo "Thành công: Đã tạo nhóm 'quickbite'."
else
    echo "Bỏ qua: Nhóm 'quickbite' đã tồn tại."
fi

if ! getent passwd quickbite > /dev/null 2>&1; then
    sudo useradd -r -g quickbite -s /bin/false quickbite
    echo "Thành công: Đã tạo user 'quickbite'."
else
    echo "Bỏ qua: User 'quickbite' đã tồn tại."
fi
