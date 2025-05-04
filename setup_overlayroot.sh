#!/usr/bin/env bash
set -euo pipefail

# —————— Konfigurasi ——————
URL="http://toxa.byethost7.com/generate_uuid.php"
OUTFILE="/etc/uuidv4.ini"
# ————————————————————————

# Fetch UUIDv4
UUID=$(curl -fsSL "$URL") || {
  echo "Error: gagal mengambil UUID dari $URL" >&2
  exit 1
}

# Validasi sederhana: UUID v4 seharusnya panjang 36 dan ada 4 dash
if [[ ! "$UUID" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89ABab][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$ ]]; then
  echo "Error: format UUID tidak valid: '$UUID'" >&2
  exit 1
fi

# Tulis ke file .ini
cat > "$OUTFILE" <<EOF
[settings]
uuid=$UUID
EOF

echo "UUID tersimpan di $OUTFILE"
