#!/usr/bin/env php
<?php
/**
 * Fetch WordPress Trac ticket discussion (comments) as markdown.
 *
 * Usage: wp-trac-ticket-discussion.php <ticket-number>
 */

if ($argc < 2) {
    fwrite(STDERR, "Usage: wp-trac-ticket-discussion.php <ticket-number>\n");
    exit(1);
}

// Extract ticket number from input (handle URLs and # prefix)
$input = $argv[1];
if (preg_match('/ticket\/(\d+)/', $input, $matches)) {
    $ticket_num = $matches[1];
} else {
    $ticket_num = ltrim($input, '#');
}

// Validate ticket number is numeric
if (!ctype_digit($ticket_num)) {
    fwrite(STDERR, "Error: Invalid ticket number: {$argv[1]}\n");
    exit(1);
}

// Fetch ticket HTML
$url = "https://core.trac.wordpress.org/ticket/{$ticket_num}";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_USERAGENT, 'wp-trac-ticket-discussion/1.0');
$html = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
unset($ch);

if ($http_code < 200 || $http_code >= 300) {
    fwrite(STDERR, "Error: Could not fetch ticket #{$ticket_num} (HTTP {$http_code})\n");
    exit(1);
}

// Parse HTML with Dom\HTMLDocument (PHP 8.4+)
$doc = Dom\HTMLDocument::createFromString($html, LIBXML_NOERROR);

// Find all change divs that don't contain chat-bot comments
$changes = $doc->querySelectorAll('div.change');

$comments = [];

foreach ($changes as $change) {
    // Skip chat-bot comments
    if ($change->querySelector('.chat-bot')) {
        continue;
    }

    // Extract comment number
    $cnum_el = $change->querySelector('.cnum');
    $cnum = $cnum_el ? trim($cnum_el->textContent) : '';

    // Extract author
    $author_el = $change->querySelector('.username .trac-author');
    $author = $author_el ? trim($author_el->textContent) : '';

    // Extract comment text
    $comment_el = $change->querySelector('.comment');
    $comment_text = $comment_el ? convertHTML($comment_el) : '';

    // Only include if there's actual comment content
    if (!empty($comment_text)) {
        $comments[] = [
            'number' => $cnum,
            'author' => $author,
            'text' => $comment_text,
        ];
    }
}

function convertHTML(Dom\Element $node): string {
    $result = '';

    foreach ($node->childNodes as $child) {
        if ($child->nodeType === XML_TEXT_NODE) {
            $result .= $child->textContent;
        } elseif ($child->nodeType === XML_ELEMENT_NODE) {
            switch ($child->tagName) {
                case 'BR':
                    $result .= "\n";
                    break;
                case 'P':
                    $result .= "\n\n" . convertHTML($child) . "\n\n";
                    break;
                case 'CODE':
                    $result .= "`{$child->textContent}`";
                    break;
                case 'PRE':
                    $class = $child->getAttribute('class') ?? '';
                    $lang = '';
                    if ($class && preg_match('/\bwiki-code-(\w+)\b/', $class, $matches)) {
                        $lang = $matches[1];
                    }
                    $result .= "\n\n```{$lang}\n" . trim($child->textContent) . "\n```\n\n";
                    break;
                case 'A':
                    $href = $child->getAttribute('href') ?? '';
                    $text = trim($child->textContent);
                    // Make relative URLs absolute
                    if ($href && str_starts_with($href, '/')) {
                        $href = "https://core.trac.wordpress.org{$href}";
                    }
                    if (!empty($href) && !empty($text)) {
                        $result .= "[{$text}]({$href})";
                    } else {
                        $result .= $text;
                    }
                    break;
                case 'STRONG':
                case 'B':
                    $result .= '**' . convertHTML($child) . '**';
                    break;
                case 'EM':
                case 'I':
                    $result .= '_' . convertHTML($child) . '_';
                    break;
                case 'UL':
                case 'OL':
                    $result .= "\n" . convertHTML($child) . "\n";
                    break;
                case 'LI':
                    $result .= "- " . convertHTML($child) . "\n";
                    break;
                case 'BLOCKQUOTE':
                    $quoted = convertHTML($child);
                    $quoted = preg_replace('/^/m', '> ', $quoted);
                    $result .= "\n" . $quoted . "\n";
                    break;
                default:
                    $result .= convertHTML($child);
                    break;
            }
        }
    }

    // Clean up excessive whitespace
    return preg_replace('/\n{3,}/', "\n\n", trim($result, " \t\n\r\f"));
}

// Output as markdown
echo "# Trac Ticket #{$ticket_num} Discussion\n\n";

if (empty($comments)) {
    echo "_No comments found._\n";
} else {
    foreach ($comments as $comment) {
		echo <<<COMMENT
			## {$comment['author']} ({$comment['number']})
			
			{$comment['text']}


			COMMENT;
    }
}
