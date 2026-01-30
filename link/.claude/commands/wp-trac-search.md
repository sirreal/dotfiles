---
description: Search WordPress Trac tickets
allowed-tools:
  - Bash(~/.claude/scripts/wp-trac-search.php:*)
argument-hint: <description of what to search for>
context: fork
---

Search WordPress Trac tickets for: $1

# Script documentation:

Search will be performed by using a command line script.
The script MUST BE invoked directly as `~/.claude/scripts/wp-trac-search.php`.
NEVER use `php` to call the script.

## Script documentation guide

!`~/.claude/scripts/wp-trac-search.php --help`

# Translation Guide

When translating natural language to CLI arguments:

- "open tickets" → --status=new --status=assigned --status=accepted --status=reopened --status=reviewing
- "closed tickets" → --status=closed
- Only use --component when there's a very obvious match to an exact component name (e.g., "HTML API", "REST API")
- When in doubt, use --summary and --description text search instead of --component
- Use --summary for text search in ticket title
- Use --description for text search in ticket body

# Examples

| User request | CLI arguments |
|--------------|---------------|
| "open HTML API tickets" | --component="HTML API" --status=new --status=assigned --status=accepted --status=reopened --status=reviewing |
| "closed REST API bugs" | --component="REST API" --status=closed --type="defect (bug)" |
| "tickets about block editor" | --summary="block editor" --description="block editor" |

# Instructions

1. Parse the user's description to identify filters and search terms
2. Build the correct CLI arguments using the documented options
3. Run: `~/.claude/scripts/wp-trac-search.php [arguments]`
4. Review results - it's expected to try several different queries to find good results
5. Try different combinations: broader/narrower searches, different text terms, with/without component filters
6. Return the final results
