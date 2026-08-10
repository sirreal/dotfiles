#!/usr/bin/env bash
# slug.sh — deterministic path → slug for the docs-review-fix pipeline.
#
# Usage: slug.sh <repo-relative-path>
# Example:
#   slug.sh packages/dataviews/README.md  →  packages__dataviews__README
#   slug.sh docs/getting-started/tutorial.md  →  docs__getting-started__tutorial

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "usage: $0 <repo-relative-path>" >&2
    exit 1
fi

path="$1"
# strip .md (and .markdown) suffix, then replace / with __
slug="${path%.md}"
slug="${slug%.markdown}"
slug="${slug//\//__}"
printf '%s\n' "$slug"
