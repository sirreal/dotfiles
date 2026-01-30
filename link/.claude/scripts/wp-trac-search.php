#!/usr/bin/env php
<?php
/**
 * Fetch WordPress Trac query results as markdown table.
 *
 * Usage: wp-trac-search.php [options]
 */

$help = <<<'HELP'
wp-trac-search.php [options]

Filter options (exact match):
  --component=VALUE    Filter by component
  --status=VALUE       Filter by status
  --type=VALUE         Filter by type
  --milestone=VALUE    Filter by milestone (e.g., "6.8", "Awaiting Review", "Future Release")
  --owner=VALUE        Filter by owner username
  --reporter=VALUE     Filter by reporter username
  --focuses=VALUE      Filter by focus area
  --priority=VALUE     Filter by priority
  --resolution=VALUE   Filter by resolution (for closed tickets)

Search options (contains match):
  --summary=VALUE      Search in ticket summary
  --description=VALUE  Search in ticket description
  --keywords=VALUE     Search in keywords

Sort options:
  --order=FIELD        Sort by field (id, summary, status, priority, etc.)
  --sort=asc|desc      Sort direction (default: asc)

Other:
  --url=URL            Use raw Trac query URL instead of building from args
  --help               Show this help

Repeat an option for AND logic: --status=new --status=assigned

Recognized values:

  Components: AI, Administration, Application Passwords, Autosave, Bootstrap/Load,
    Build/Test Tools, Bundled Theme, Cache API, Canonical, Charset, Comments,
    Cron API, Customize, Database, Date/Time, Editor, Embeds, Emoji, Export,
    External Libraries, Feeds, Filesystem API, Formatting, Gallery, General,
    HTML API, HTTP API, Help/About, I18N, Import, Interactivity API,
    Login and Registration, Mail, Media, Menus, Networks and Sites, Notes,
    Options, Meta APIs, Permalinks, Pings/Trackbacks, Plugins, Post Formats,
    Post Thumbnails, Posts, Post Types, Privacy, Query, Quick/Bulk Edit,
    REST API, Revisions, Rewrite Rules, Role/Capability, Script Loader,
    Security, Shortcodes, Site Health, Sitemaps, Taxonomy, Text Changes,
    Themes, TinyMCE, Toolbar, Upgrade/Install, Upload, Users, Widgets,
    WordPress.org Site, XML-RPC

  Focuses: ui, accessibility, javascript, css, tests, docs, rtl, administration,
    template, multisite, rest-api, performance, privacy, sustainability, ui-copy,
    coding-standards, php-compatibility

  Status: new, assigned, accepted, closed, reopened, reviewing

  Type: defect (bug), enhancement, feature request, task (blessed)

  Priority: highest omg bbq, high, normal, low, lowest

  Resolution: fixed, invalid, wontfix, duplicate, worksforme, maybelater,
    reported-upstream
HELP;

// Parse command line options
$longopts = [
    'component:',
    'status:',
    'type:',
    'milestone:',
    'owner:',
    'reporter:',
    'focuses:',
    'priority:',
    'resolution:',
    'summary:',
    'description:',
    'keywords:',
    'order:',
    'sort:',
    'url:',
    'help',
];

$options = getopt('', $longopts);

// Show help if no args or --help
if ($argc < 2 || isset($options['help'])) {
    echo $help . "\n";
    exit(0);
}

// Build URL from options or use --url directly
if (isset($options['url'])) {
    $url = $options['url'];
    // Validate URL starts with Trac query endpoint
    if (strpos($url, 'https://core.trac.wordpress.org/query') !== 0) {
        fwrite(STDERR, "Error: URL must start with https://core.trac.wordpress.org/query\n");
        exit(1);
    }
} else {
    // Build query parameters from CLI args
    $params = [];

    // Exact match fields
    $exact_fields = ['component', 'status', 'type', 'milestone', 'owner', 'reporter', 'focuses', 'priority', 'resolution'];
    foreach ($exact_fields as $field) {
        if (isset($options[$field])) {
            $values = (array) $options[$field];
            foreach ($values as $value) {
                $params[] = [$field, $value];
            }
        }
    }

    // Contains match fields (prepend ~ for contains)
    $contains_fields = ['summary', 'description', 'keywords'];
    foreach ($contains_fields as $field) {
        if (isset($options[$field])) {
            $values = (array) $options[$field];
            foreach ($values as $value) {
                $params[] = [$field, '~' . $value];
            }
        }
    }

    // Sort options
    if (isset($options['order'])) {
        $params[] = ['order', $options['order']];
    }
    if (isset($options['sort']) && $options['sort'] === 'desc') {
        $params[] = ['desc', '1'];
    }

    // Build query string (handle repeated params manually)
    $query_parts = [];
    foreach ($params as [$key, $value]) {
        $query_parts[] = urlencode($key) . '=' . urlencode($value);
    }
    $query_string = implode('&', $query_parts);

    $url = 'https://core.trac.wordpress.org/query' . ($query_string ? '?' . $query_string : '');
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
