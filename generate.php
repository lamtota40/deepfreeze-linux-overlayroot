<?php
/**
 * Generate a UUID v4 (random).
 * @return string 36‐character UUID, e.g. "3f0e3a2c-1b4f-4d5e-9a7b-6e8f9c0d1b2a"
 */
function generateUUIDv4(): string {
    // Ambil 16 byte acak
    $data = random_bytes(16);

    // Set versi ke 0100 (UUID v4)
    $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
    // Set variant ke 10xx
    $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);

    // Format jadi string UUID
    return vsprintf(
        '%02s%02s%02s%02s-%02s%02s-%02s%02s-%02s%02s-%02s%02s%02s%02s%02s',
        str_split(bin2hex($data), 2)
    );
}

// Contoh penggunaan:
echo generateUUIDv4();
?>
