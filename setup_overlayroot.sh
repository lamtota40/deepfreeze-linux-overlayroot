#!/bin/bash

# Menu sederhana untuk mengelola overlayroot sebagai pengganti fsprotect

set -e

overlay_conf="/etc/overlayroot.conf"

check_status() {
#!/bin/bash

# Cek apakah file /etc/overlayroot.conf ada
if [ -f "$overlay_conf" ]; then
    value=$(grep -E '^overlayroot=' "$overlay_conf" | cut -d'=' -f2)

    if [ "$value" == "" ]; then
        echo "Sudah terinstal, status: disable"
    elif [ "$value" == "tmpfs" ]; then
        echo "Sudah terinstal, status: enable"
    else
        echo "Sudah terinstal, status: unknown"
     if
else
    echo "Belum terinstal"
fi

}


install_overlayroot() {
    echo "> Installing overlayroot..."
    apt update && apt install -y overlayroot
    echo "overlayroot installed."
}

enable_overlayroot() {
    echo "> Enabling overlayroot..."
    echo 'overlayroot="tmpfs"' > "$overlay_conf"
    echo "overlayroot enabled. Please reboot to take effect."
}

disable_overlayroot() {
    echo "> Disabling overlayroot..."
    echo 'overlayroot="disabled"' > "$overlay_conf"
    echo "overlayroot disabled. Please reboot to take effect."
}

uninstall_overlayroot() {
    echo "> Uninstalling overlayroot..."
    apt purge -y overlayroot
    rm -f "$overlay_conf"
    rm -f /etc/uuidv4.ini
    echo "overlayroot uninstalled."
}

# Menu utama
while true; do
    echo "==============="
    echo "Menu OVERLAYROOT"
    echo "==============="
    echo "Status: $(check_status)"
    echo
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
        0) exit 0 ;;
        *) echo "Pilihan tidak valid." ;;
    esac
done
