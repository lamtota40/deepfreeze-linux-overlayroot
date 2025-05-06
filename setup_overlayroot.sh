#!/bin/bash

set -e
overlay_conf="/etc/overlayroot.conf"
pause() {
  read -p "Press Enter to return to the menu..."
}

rescueboot() {
sudo apt install grml-rescueboot zsh -y
mkdir -p /etc/grml/partconf
sudo wget raw.githubusercontent.com/lamtota40/deepfreeze-linux-overlayroot/main/auto-run-grml.sh -P /etc/grml/partconf
sudo bash -c "echo 'CUSTOM_BOOTOPTIONS=\"ssh=pas123 dns=8.8.8.8,8.8.4.4 netscript=raw.githubusercontent.com/lamtota40/deepfreeze-linux-overlayroot/main/auto-run-grml.sh toram\"' >> /etc/default/grml-rescueboot"
mkdir -p /boot/grml
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    echo "Terdeteksi sistem 64-bit"
    if [ ! -f /boot/grml/grml64-small_2024.02.iso ]; then
    wget https://ftp2.osuosl.org/pub/grml/grml64-small_2024.02.iso -P /boot/grml/
    fi
    GRML_ENTRY='Grml Rescue System (grml64-small_2024.02.iso)'
elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
    echo "Terdeteksi sistem 32-bit"
    if [ ! -f /boot/grml/grml32-small_2024.02.iso ]; then
    wget https://ftp2.osuosl.org/pub/grml/grml32-small_2024.02.iso -P /boot/grml/
    fi
    GRML_ENTRY='Grml Rescue System (grml32-small_2024.02.iso)'
else
    echo "Arsitektur tidak dikenali: $ARCH"
    GRML_ENTRY=''
    exit 1
fi
 
 #sudo sed -i "s|^GRUB_DEFAULT=.*|GRUB_DEFAULT=\"${GRML_ENTRY}\"|" /etc/default/grub
 sudo update-grub
 sudo grub-reboot "$GRML_ENTRY"

cat <<EOF > /etc/systemd/system/autobootgrml.service
[Unit]
Description=Always set boot to GRML
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/grub-reboot "$GRML_ENTRY"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable autobootgrml.service
  }

check_status() {
if ! command -v overlayroot-chroot >/dev/null 2>&1; then
    echo "Belum Terinstal"
else
    value=$(overlayroot-chroot cat /etc/overlayroot.conf 2>/dev/null | grep '^overlayroot=' | cut -d= -f2 | tr -d '"')
    if [[ "$value" == "tmpfs" || "$value" == "overlay" ]]; then
        echo "Sudah Terinstal (Enable)"
    else
        echo "Sudah Terinstal (Disable)"
    fi
fi
}

install_overlayroot() {
    echo "> Installing overlayroot..."
    apt update && apt install -y overlayroot
    echo "overlayroot installed."
    pause
}

enable_overlayroot() {
    echo "> Enabling overlayroot..."
    if [ ! -f /etc/overlayroot.conf.bak ]; then
    cp "$overlay_conf" /etc/overlayroot.conf.bak
    fi
    echo -n > "$overlay_conf"
    echo 'overlayroot="tmpfs"' > "$overlay_conf"
    echo "overlayroot enabled. Please reboot to take effect."
}

disable_overlayroot() {
    echo "> Disabling overlayroot..."
    echo 'overlayroot="disabled"' > "$overlay_conf"
    echo "overlayroot disabled. Please reboot to take effect."
}

uninstall_overlayroot() {
    echo "> Memeriksa status overlayroot..."
    if ! command -v overlayroot-chroot >/dev/null 2>&1; then
        echo "> overlayroot tidak terinstal. Tidak perlu uninstall."
        return
    fi

    value=$(overlayroot-chroot cat /etc/overlayroot.conf 2>/dev/null | grep '^overlayroot=' | cut -d= -f2 | tr -d '"')
    if [[ "$value" == "tmpfs" || "$value" == "overlay" ]]; then
        echo "> overlayroot dalam kondisi ENABLE. Uninstall tidak dapat dilakukan saat aktif."
        echo "> Silakan nonaktifkan terlebih dahulu melalui konfigurasi dan reboot."
        return
    fi

    echo "> Uninstalling overlayroot..."
    cp /etc/overlayroot.conf.bak "$overlay_conf"
    apt purge -y overlayroot
    rm -f "$overlay_conf"
    rm -f /etc/uuidv4.ini
    echo "> overlayroot berhasil di-uninstall."
}

# Menu utama
while true; do
    echo "==============="
    echo "Menu OVERLAYROOT"
    echo "==============="
    echo "Status: $(check_status)"
    echo ""
    echo "1. Install OverlayRoot"
    echo "2. Enable FREEZE"
    echo "3. Disable FREEZE"
    echo "4. Uninstall OverlayRoot"
    echo "0. Exit"
    read -p "Silahkan input pilihan anda: " opsi

    case $opsi in
        1) install_overlayroot ;;
        2) enable_overlayroot ;;
        3) disable_overlayroot ;;
        4) uninstall_overlayroot ;;
        5) rescueboot ;;
        0) exit 0 ;;
        *) echo "Pilihan tidak valid." ;;
    esac
done
