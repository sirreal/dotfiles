---
name: docs-writing-pass
description: Run a parallel-agent (Haiku) writing-quality pass over markdown docs in a repo — fixes spelling, grammar, punctuation, and markdown syntax only. Use when the user wants to fan out agents to review or fix typos across documentation, do a writing pass over all docs, or improve doc quality across a codebase.
---

# Docs writing-quality pass

Light-touch spelling/grammar/punctuation/markdown-syntax fixes across every markdown file in a repo. The orchestrator handles discovery, batching, audit, and commits; Haiku agents do the per-file reading and editing in parallel.

## Phase 1: Discovery

Find candidate `.md` files. Exclude only what's truly uneditable:

```bash
find . -name "*.md" -type f \
  -not -path "*/node_modules/*" -not -path "./.git/*" \
  -not -path "*/dist/*" -not -path "*/build/*" \
  -not -path "*/.next/*" -not -path "*/coverage/*" \
  -not -name "LICENSE.md" -not -name "THIRD_PARTY_NOTICES.md" \
  > "$CLAUDE_JOB_DIR/candidates.txt"
```

Eyeball the list. Drop any clearly auto-generated `CHANGELOG.md` (templated `## [x.y.z]` blocks); hand-written ones stay. If a feature branch is already in progress, filter out files already touched: `git diff --name-only <base>...HEAD -- '*.md'`.

## Phase 2: Batching

Split into 20–24 batches:

```bash
split -n l/24 -d -a 2 "$CLAUDE_JOB_DIR/candidates.txt" "$CLAUDE_JOB_DIR/batch_"
```

## Phase 3: Dispatch

Spawn one Haiku Agent per batch in parallel (background). Use this prompt, substituting the batch path:

> Light-touch writing-quality pass on a batch of docs. STRICT scope.
>
> Read `$CLAUDE_JOB_DIR/batch_NN` for the file list (paths relative to repo root). Process each independently.
>
> **In-scope only:**
> - Spelling
> - Grammar (subject/verb agreement, tense, articles, dangling phrases)
> - Punctuation (commas, periods, `it's`/`its`)
> - Markdown syntax: malformed `[text](url)`, unclosed code fences, unclosed bold/italic, heading-level skipping, missing blank line around fenced blocks/headings
>
> **Out-of-scope — skip even if you spot them:**
> - Rewrites for style, tone, clarity
> - Dead links, stale URLs, outdated APIs, wrong file paths
> - Command/package/file/identifier names, code samples, import paths — even if you believe they are wrong
> - Adding/removing sections, lines, examples
> - Hyphen vs em-dash, whitespace style
> - `LICENSE.md`, `THIRD_PARTY_NOTICES.md`
>
> If the only problem is a real correctness issue (wrong command, wrong import), LEAVE IT.
>
> **Quote preservation:** if the repo enforces curly quotes/apostrophes (“ ” ‘ ’), preserve them exactly. When editing a line with curly quotes, match on an inner substring that doesn't include the surrounding straight-quote delimiters.
>
> Read each file. Apply only in-scope fixes with Edit. Skim fast. Do NOT run git. Do NOT commit.
>
> Output: one line per change: `path/to/file.md: "old" → "new" (brief reason)`. End with `No fixes: N files`. Under ~600 words.

## Phase 4: Audit (do not skip)

Agents produce 5–10% false positives. For each modified file, run `git diff <file>` and reject:

- Sentence rewrites disguised as grammar fixes
- Code-sample edits (identifiers, import paths, command names) — `grep` source if unsure
- Component/API name "corrections" — verify against source first
- "Fixes" to text that was already correct
- Style-convention edits across parallel files (removing intentional patterns)
- Partial fixes (typo fixed on one line, same typo left on another)

Revert with Edit. Avoid `git checkout --`; it discards uncommitted work without confirmation.

## Phase 5: Commit per-file

Match the incremental-cleanup convention with one commit per file:

```bash
git add "$1" && git commit -q -m "docs: fix $1

$2"
```

Generate bullet messages from the actual diff. Terse — what changed, not why.

## Notes

- Haiku is cheap; favor more agents over larger batches. 30–45 files per agent works.
- If the repo has `CLAUDE.md`/`AGENTS.md` with style or quote conventions, propagate them into the agent prompt.
- For 1000+ md repos, expect a ~5–10% in-scope hit rate.
