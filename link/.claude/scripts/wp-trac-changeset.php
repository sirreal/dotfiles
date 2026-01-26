#!/usr/bin/env php
<?php
/**
 * Fetch WordPress Trac changeset info as markdown.
 *
 * Usage: wp-trac-changeset.php <changeset-number>
 */

if ($argc < 2) {
    fwrite(STDERR, "Usage: wp-trac-changeset.php <changeset-number>\n");
    exit(1);
}

// Strip leading 'r' or 'R' if present (e.g., r61418 -> 61418)
$changeset_num = ltrim($argv[1], 'rR');

// Validate changeset number is numeric
if (!ctype_digit($changeset_num)) {
    fwrite(STDERR, "Error: Invalid changeset number: {$argv[1]}\n");
    exit(1);
}

// Fetch changeset HTML
$url = "https://core.trac.wordpress.org/changeset/{$changeset_num}";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_USERAGENT, 'wp-trac-changeset/1.0');
$html = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
unset($ch);

if ($http_code < 200 || $http_code >= 300) {
    fwrite(STDERR, "Error: Could not fetch changeset r{$changeset_num} (HTTP {$http_code})\n");
    exit(1);
}

// Parse HTML with Dom\HTMLDocument (PHP 8.4+)
$doc = Dom\HTMLDocument::createFromString($html, LIBXML_NOERROR);

// Find the overview dl element
$overview = $doc->querySelector('#overview');
if (!$overview) {
    fwrite(STDERR, "Error: Could not parse changeset r{$changeset_num}\n");
    exit(1);
}

// Extract fields from the overview using CSS selectors
$timestamp_el = $overview->querySelector('dd.time');
$timestamp = $timestamp_el ? preg_replace('/\s+/', ' ', trim($timestamp_el->textContent)) : '';

$author_el = $overview->querySelector('dd.author');
$author = $author_el ? trim($author_el->textContent) : '';

$message_el = $overview->querySelector('dd.message');
$message = $message_el ? convertHtmlToMarkdown($message_el) : '';

// Location dd has class "searchable" but not "message"
$location_el = $overview->querySelector('dt.location + dd a');
$location = $location_el ? trim($location_el->textContent) : '';

/**
 * Convert HTML content to markdown.
 */
function convertHtmlToMarkdown(Dom\Node $node): string {
    $result = '';

    foreach ($node->childNodes as $child) {
        if ($child->nodeType === XML_TEXT_NODE) {
            $result .= $child->textContent;
        } elseif ($child->nodeType === XML_ELEMENT_NODE) {
            $tagName = strtolower($child->nodeName);

            switch ($tagName) {
                case 'br':
                    $result .= "\n";
                    break;
                case 'p':
                    $result .= "\n\n" . convertHtmlToMarkdown($child) . "\n\n";
                    break;
                case 'code':
                    $result .= '`' . $child->textContent . '`';
                    break;
                case 'a':
                    $href = $child->getAttribute('href');
                    $text = trim($child->textContent);
                    // Make relative URLs absolute
                    if ($href && str_starts_with($href, '/')) {
                        $href = 'https://core.trac.wordpress.org' . $href;
                    }
                    if ($href && $text) {
                        $result .= "[{$text}]({$href})";
                    } else {
                        $result .= $text;
                    }
                    break;
                case 'strong':
                case 'b':
                    $result .= '**' . convertHtmlToMarkdown($child) . '**';
                    break;
                case 'em':
                case 'i':
                    $result .= '*' . convertHtmlToMarkdown($child) . '*';
                    break;
                default:
                    $result .= convertHtmlToMarkdown($child);
                    break;
            }
        }
    }

    // Clean up excessive whitespace
    $result = preg_replace('/\n{3,}/', "\n\n", $result);
    return trim($result);
}

// Output as markdown
echo "# Trac Changeset r{$changeset_num}\n";
echo "\n";
echo "**Timestamp:** {$timestamp}\n";
echo "**Author:** {$author}\n";
if ($location) {
    echo "**Location:** {$location}\n";
}
echo "\n";
echo "## Message\n";
echo "\n";
echo "{$message}\n";
