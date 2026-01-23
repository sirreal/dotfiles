#!/usr/bin/env php
<?php
/**
 * Fetch WordPress Trac ticket info as markdown.
 *
 * Usage: wp-trac-ticket.php <ticket-number>
 */

if ($argc < 2) {
    fwrite(STDERR, "Usage: wp-trac-ticket.php <ticket-number>\n");
    exit(1);
}

// Strip leading # if present
$ticket_num = ltrim($argv[1], '#');

// Validate ticket number is numeric
if (!ctype_digit($ticket_num)) {
    fwrite(STDERR, "Error: Invalid ticket number: {$ticket_num}\n");
    exit(1);
}

// Fetch ticket data in TSV format, streaming directly to a temp file
$url = "https://core.trac.wordpress.org/ticket/{$ticket_num}?format=tab";
$stream = fopen('php://temp', 'r+');

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_FILE, $stream);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_USERAGENT, 'wp-trac-ticket/1.0');
curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if ($http_code < 200 || $http_code >= 300) {
    fwrite(STDERR, "Error: Could not fetch ticket #{$ticket_num}\n");
    exit(1);
}

// Parse TSV using fgetcsv which handles multiline quoted fields
rewind($stream);
$headers = fgetcsv($stream, 0, "\t", '"', '');
$values = fgetcsv($stream, 0, "\t", '"', '');
fclose($stream);

if ($headers === false || $values === false) {
    fwrite(STDERR, "Error: Invalid response for ticket #{$ticket_num}\n");
    exit(1);
}

// Strip BOM from first header if present
$headers[0] = preg_replace('/^\xEF\xBB\xBF/', '', $headers[0]);

if (count($headers) !== count($values)) {
    fwrite(STDERR, "Error: Malformed TSV data for ticket #{$ticket_num}\n");
    exit(1);
}

// Create associative array
$ticket = array_combine($headers, $values);

// Convert Trac wiki syntax to markdown
$description = $ticket['description'];
// Convert code fence openers: {{{#!lang -> ```lang (xml becomes html)
$description = preg_replace_callback(
    '/^\{\{\{(?:#!(\w+))?\r?$/m',
    function ($matches) {
        $lang = $matches[1] ?? '';
        if ($lang === 'xml') {
            $lang = 'html';
        }
        return '```' . $lang;
    },
    $description
);
// Convert code fence closers: }}} -> ```
$description = preg_replace('/^\}\}\}\r?$/m', '```', $description);

// Output as markdown
echo "# Trac Ticket #{$ticket['id']}\n";
echo "\n";
echo "**Component:** {$ticket['component']}\n";
echo "**Summary:** {$ticket['summary']}\n";
echo "**Type:** {$ticket['type']}\n";
echo "**Status:** {$ticket['status']}\n";
echo "**Milestone:** {$ticket['milestone']}\n";
echo "\n";
echo "## Description\n";
echo "\n";
echo "{$description}\n";
echo "\n";
echo "**Keywords:** {$ticket['keywords']}\n";
echo "**Focuses:** {$ticket['focuses']}\n";
