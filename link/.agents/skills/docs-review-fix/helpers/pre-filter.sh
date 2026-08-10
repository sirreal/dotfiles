#!/usr/bin/env bash
# pre-filter.sh — detect auto-generated docs that should be excluded from
# the per-file review pipeline and surfaced under cross-cutting instead.
#
# Usage:
#   pre-filter.sh <repo-root> < input-file-list > kept-file-list
#   pre-filter.sh <repo-root> --report excluded.json < input-file-list > kept-file-list
#
# Reads file paths (one per line, repo-relative) from stdin. Emits the kept
# paths to stdout. With --report, also writes a JSON array of excluded paths
# to the given path.

set -euo pipefail

REPO_ROOT=""
REPORT_PATH=""

while [ $# -gt 0 ]; do
    case "$1" in
        --report)
            REPORT_PATH="$2"
            shift 2
            ;;
        *)
            if [ -z "$REPO_ROOT" ]; then
                REPO_ROOT="$1"
                shift
            else
                echo "unexpected arg: $1" >&2
                exit 1
            fi
            ;;
    esac
done

if [ -z "$REPO_ROOT" ]; then
    echo "usage: $0 <repo-root> [--report path.json] < file-list" >&2
    exit 1
fi

excluded=()

while IFS= read -r rel; do
    # skip empty / comment lines
    [ -z "$rel" ] && continue
    case "$rel" in '#'*) continue ;; esac

    abs="$REPO_ROOT/$rel"
    if [ ! -f "$abs" ]; then
        # missing file — skip silently; orchestrator validates separately
        continue
    fi

    if head -n 50 "$abs" 2>/dev/null | grep -qE '<!-- START TOKEN|auto-generated|Auto-generated|AUTO-GENERATED|DO NOT EDIT|@generated'; then
        excluded+=("$rel")
    else
        printf '%s\n' "$rel"
    fi
done

if [ -n "$REPORT_PATH" ]; then
    mkdir -p "$(dirname "$REPORT_PATH")"
    {
        printf '['
        first=1
        for f in "${excluded[@]+"${excluded[@]}"}"; do
            if [ $first -eq 1 ]; then first=0; else printf ','; fi
            # naive JSON-string escape: assumes paths don't contain " or \
            printf '"%s"' "$f"
        done
        printf ']\n'
    } > "$REPORT_PATH"
fi

if [ ${#excluded[@]} -gt 0 ]; then
    echo "pre-filter: excluded ${#excluded[@]} auto-generated file(s)" >&2
fi
