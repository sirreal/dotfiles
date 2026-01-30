#!/usr/bin/env php
<?php
/**
 * Fetch WordPress Trac query results as markdown table.
 *
 * Usage: wp-trac-search.php <query-url>
 */

if ($argc < 2) {
    fwrite(STDERR, "Usage: wp-trac-search.php <query-url>\n");
    exit(1);
}

$url = $argv[1];

// Validate URL starts with Trac query endpoint
if (strpos($url, 'https://core.trac.wordpress.org/query') !== 0) {
    fwrite(STDERR, "Error: URL must start with https://core.trac.wordpress.org/query\n");
    exit(1);
}

// Append &format=tab if missing
if (strpos($url, 'format=tab') === false) {
    $url .= (strpos($url, '?') !== false ? '&' : '?') . 'format=tab';
}

// Fetch query results, streaming to temp file
$stream = fopen('php://temp', 'r+');

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_FILE, $stream);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_USERAGENT, 'wp-trac-search/1.0');
curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
unset($ch);

if ($http_code < 200 || $http_code >= 300) {
    fwrite(STDERR, "Error: Could not fetch query results (HTTP {$http_code})\n");
    exit(1);
}

// Parse TSV using fgetcsv which handles multiline quoted fields
rewind($stream);
$headers = fgetcsv($stream, 0, "\t", '"', '');

if ($headers === false) {
    fwrite(STDERR, "Error: Invalid response - no headers found\n");
    exit(1);
}

// Strip BOM from first header if present
$headers[0] = preg_replace('/^\xEF\xBB\xBF/', '', $headers[0]);

// Read all rows
$rows = [];
while (($row = fgetcsv($stream, 0, "\t", '"', '')) !== false) {
    if (count($row) === count($headers)) {
        $rows[] = array_combine($headers, $row);
    }
}
fclose($stream);

if (empty($rows)) {
    echo "No tickets found.\n";
    exit(0);
}

// Escape pipe characters for markdown table cells
function escape_cell($value) {
    return str_replace('|', '\\|', $value);
}

// Create lowercase header lookup map
$header_lower = array_map('strtolower', $headers);
$header_map = array_combine($header_lower, $headers);

// Determine which columns to display (use id, summary, status, component if available)
$display_cols = [];
$preferred = ['id', 'summary', 'status', 'component', 'type', 'milestone'];
foreach ($preferred as $col) {
    if (isset($header_map[$col])) {
        $display_cols[] = $header_map[$col];
    }
}

// Fall back to all columns if preferred ones not found
if (empty($display_cols)) {
    $display_cols = $headers;
}

// Build table data and calculate column widths
$table_headers = [];
$table_rows = [];
$col_widths = [];

foreach ($display_cols as $col) {
    $header = ucfirst(escape_cell($col));
    $table_headers[] = $header;
    $col_widths[] = mb_strlen($header);
}

foreach ($rows as $row) {
    $cells = [];
    foreach ($display_cols as $i => $col) {
        $value = escape_cell($row[$col] ?? '');
        $cells[] = $value;
        $col_widths[$i] = max($col_widths[$i], mb_strlen($value));
    }
    $table_rows[] = $cells;
}

// Output padded markdown table
$padded = [];
foreach ($table_headers as $i => $header) {
    $padded[] = str_pad($header, $col_widths[$i]);
}
echo '| ' . implode(' | ', $padded) . " |\n";

$separators = [];
foreach ($col_widths as $width) {
    $separators[] = str_repeat('-', $width);
}
echo '|-' . implode('-|-', $separators) . "-|\n";

foreach ($table_rows as $cells) {
    $padded = [];
    foreach ($cells as $i => $cell) {
        $padded[] = str_pad($cell, $col_widths[$i]);
    }
    echo '| ' . implode(' | ', $padded) . " |\n";
}

echo "\n" . count($rows) . " ticket(s) found.\n";
