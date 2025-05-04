#!/usr/bin/env bash
set -euo pipefail

# —————— Konfigurasi ——————
UUID_FILE="/etc/uuidv4.ini"       # File yang berisi UUID
SAVE_URL="http://toxa.byethost7.com/save_flag.php"  # Endpoint PHP untuk menyimpan flag
OR_CONF="/etc/overlayroot.conf"  # File overlayroot.conf
# ————————————————————————

# Prompt user untuk flag
while true; do
  read -rp "Enter flag (0 = enable overlayroot tmpfs, 1 = disable overlayroot): " FLAG
  case "$FLAG" in
    0|1) break;;
    *) echo "Invalid input. Please enter 0 or 1.";;
  esac
done

# Baca UUID
if [ ! -r "$UUID_FILE" ]; then
  echo "Error: cannot read $UUID_FILE" >&2
  exit 1
fi
UUID=$(awk -F= '/^uuid=/{print $2}' "$UUID_FILE")
if ! [[ "$UUID" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89ABab][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$ ]]; then
  echo "Error: invalid UUID in $UUID_FILE" >&2
  exit 1
fi

# Kirim ke server
RESPONSE=$(curl -fsSL -X POST "$SAVE_URL" \
  -d "uuid=$UUID" \
  -d "flag=$FLAG"
) || {
  echo "Error: gagal kirim ke $SAVE_URL" >&2
  exit 1
}

# Verifikasi respons
if ! echo "$RESPONSE" | grep -q '"status":"success"'; then
  echo "Error: server returned unexpected response: $RESPONSE" >&2
  exit 1
fi

# Update overlayroot.conf
if [ "$FLAG" = "1" ]; then
  echo 'overlayroot=disabled' > "$OR_CONF"
else
  echo 'overlayroot=tmpfs:swap=1,recurse=0' > "$OR_CONF"
fi

echo "✅ Flag set to $FLAG and $OR_CONF updated!"
