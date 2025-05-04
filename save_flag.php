<?php
// save_flag.php
// Simple PHP endpoint to receive UUID and flag, then save to MySQL database

// --- Database configuration ---
$host   = 'sql304.byethost7.com';       // database host
$db     = 'b7_38901489_overlayroot';   // database name
$user   = 'b7_38901489';       // database username
$pass   = 'okde';       // database password
$charset= 'utf8mb4';         // character set

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    http_response_code(500);
    exit(json_encode(['status'=>'error','message'=>'DB connection failed']));
}

// --- Retrieve inputs (GET or POST) ---
$uuid = $_REQUEST['uuid'] ?? null;\$flag = $_REQUEST['flag'] ?? null;

// Validate inputs
if (!$uuid || !preg_match('/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89ABab][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/', $uuid)) {
    http_response_code(400);
    exit(json_encode(['status'=>'error','message'=>'Invalid UUID']));
}
if (!in_array($flag, ['0','1'], true)) {
    http_response_code(400);
    exit(json_encode(['status'=>'error','message'=>'Flag must be 0 or 1']));
}

// --- Insert into database ---
$sql = "INSERT INTO flags (uuid, flag) VALUES (:uuid, :flag)";
$stmt = $pdo->prepare($sql);
$stmt->execute(['uuid' => $uuid, 'flag' => $flag]);

// --- Response ---
echo json_encode(['status'=>'success']);
