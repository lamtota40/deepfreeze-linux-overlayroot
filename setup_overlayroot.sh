#!/usr/bin/env bash
set -euo pipefail

# —————— Konfigurasi ——————
URL="http://toxa.byethost7.com/generate_uuid.php"
OUTFILE="/etc/uuidv4.ini"
# ————————————————————————

# Fungsi validasi UUIDv4
is_valid_uuid() {
  [[ "$1" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$ ]]
}

# Cek jika file sudah ada dan valid
if [[ -f "$OUTFILE" ]]; then
  EXISTING_UUID=$(awk -F= '/^uuid=/{print $2}' "$OUTFILE" | tr '[:upper:]' '[:lower:]')
  if is_valid_uuid "$EXISTING_UUID"; then
    echo "UUID sudah valid: $EXISTING_UUID"
    exit 0
  else
    echo "UUID tidak valid. Mengambil ulang..."
  fi
else
  echo "File $OUTFILE belum ada. Membuat baru..."
fi

# Ambil UUID dari server
UUID=$(curl -fsSL "$URL" | tr '[:upper:]' '[:lower:]') || {
  echo "Error: gagal mengambil UUID dari $URL" >&2
  exit 1
}

# Validasi UUID baru
if ! is_valid_uuid "$UUID"; then
  echo "Error: UUID tidak valid dari server: '$UUID'" >&2
  exit 1
fi

# Simpan ke file
cat > "$OUTFILE" <<EOF
[settings]
uuid=$UUID
EOF

echo "UUID baru disimpan di $OUTFILE: $UUID"
