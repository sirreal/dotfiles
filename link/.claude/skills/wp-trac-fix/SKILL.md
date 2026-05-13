---
name: wp-trac-fix
description: This skill should be used when the user asks to "work on Trac #N", "fix Trac ticket #N", "attempt to fix #N", "reproduce and fix #N", "take a shot at #N", or when an agent is dispatched into a wordpress-develop worktree to address a specific WordPress core Trac ticket. Encodes the disciplined workflow for reproducing and fixing WordPress core defects in envlite-backed isolated worktrees, including evidence-grade NOT-REPRODUCIBLE / INCONCLUSIVE outcomes when appropriate.
---

# wp-trac-fix

Reproduce and fix a WordPress core defect from Trac in an isolated worktree, with discipline that produces evidence-grade outcomes — including NOT-REPRODUCIBLE / INCONCLUSIVE classifications when the bug cannot be triggered.

## Preconditions

Verify before starting:
- The current shell is in a clone of `WordPress/wordpress-develop`.
- An `upstream` remote points at `WordPress/wordpress-develop`. Confirm with `git remote get-url upstream`.
- The envlite tool is available at a stable absolute path (typically `~/a8c/wordpress-develop/add-envlite-tool/tools/local-env/envlite.php`). Confirm with `ls <path>`.

If any precondition fails, stop and report the missing piece.

## Phase 0 — Setup

Create a per-ticket worktree forked from `upstream/trunk` and initialize envlite. The slug is a kebab-case summary of the bug (1–4 words, e.g. `datepicker-footer-l10n`).

```bash
git fetch upstream
git worktree add ~/a8c/wordpress-develop/agent-fixes/<ticket> \
  -b trac-<ticket>/<slug> upstream/trunk
cd ~/a8c/wordpress-develop/agent-fixes/<ticket>
php ~/a8c/wordpress-develop/add-envlite-tool/tools/local-env/envlite.php init --force
```

envlite init runs `npm ci`, `npm run build:dev`, and `composer install` — minutes on first init. All subsequent work occurs in this worktree. Never `cd` out of it; never switch branches inside it.

## Phase A — Read the ticket

Fetch description and comments. Use the `wp-trac-ticket` skill: basic mode for description, `--discussion` for comments, `--prs` to check for existing pull requests.

Read critically — the entire ticket, not only the comments. Descriptions, sample code, and commenter conclusions are all unreliable; they may be wrong, stale, or written without ever being run.

- "Reproduction report" comments may have tested an adjacent scenario, not the actual claim. Confirm what the ticket claims is broken before accepting any commenter's conclusion. Note meaningful discrepancies in the report's notes field.
- Sample code in the description may not run as written. If a transplanted snippet throws a fatal error or has no observable effect, the snippet is broken — that is NOT evidence the underlying bug is absent. Fix the snippet, retry, then decide. See `references/repro-strategies.md` for common snippet-failure modes.

## Phase B — Reproduce

Pick a strategy from the matrix and attempt once before escalating.

| Ticket signal | Strategy |
|---|---|
| PHP API behavior | phpunit |
| Admin UI / front-end rendering / browser-specific | Playwright MCP via `envlite up` |
| Block editor / JS module / JS function correctness | qunit (CLI; open in browser via MCP for visual debugging) |
| REST / Ajax endpoints | phpunit first; escalate to Playwright MCP only if PHP harness cannot reach the codepath |
| Multisite / cron / upgrade | phpunit (multisite group / cron tests / upgrade tests) |
| Unclear, "looks wrong", "is slow" | Playwright MCP |

For browser-driven repro: run `envlite up --force` backgrounded, read port from `.envlite/port`, then drive `http://127.0.0.1:<port>/` via Playwright MCP. Admin login: `admin` / `password`.

For phpunit: `vendor/bin/phpunit --filter <test_name>` from the worktree root.

See `references/repro-strategies.md` for detailed per-strategy guidance.

### Classifications

After Phase B, classify the outcome:

- **REPRODUCED+FIXED** — reproduced concretely; fix written; tests pass.
- **REPRODUCED+UNFIXED** — reproduced, but the right fix exceeds the scope cap (see Phase C).
- **NOT-REPRODUCIBLE** — affirmative evidence the bug does not occur. Requires either:
  - Demonstrated execution of the codepath the ticket describes with no failure (add a probe; confirm it fires), or
  - Two strategies attempted, both produced no failure under conditions matching the ticket.
- **INCONCLUSIVE** — neither reproduced nor confidence-grade negative evidence within ~20 wall-clock minutes. Distinct from NOT-REPRODUCIBLE: do not claim the bug is absent.

### Repro evidence (mandatory)

Before declaring REPRODUCED, write a one-sentence comparison: "Ticket reports X fails; my repro produces Y; X ≈ Y because Z." Include this verbatim in the final report. If X and Y diverge, the reproduction is not valid — keep working or classify INCONCLUSIVE.

## Phase C — Fix

**Default: test-driven development.** Write a failing test in a standard WP test location (`tests/phpunit/tests/...` or `tests/qunit/tests/...`). Verify it fails. Implement the fix. Verify it passes.

**TDD waiver** — only for genuine UI/visual bugs where the underlying logic cannot be isolated into a function-level test. If waived, replace the report's "verification" field with the exact manual recipe (Playwright steps or shell sequence) needed to re-verify the fix. Document the waiver reason in one sentence.

### Scope

Minimal but complete. The fix touches only the lines that must change. Variables that become unused or names that become misleading as a *consequence* of the fix may be updated. Side-quests — refactoring, cleanup of pre-existing issues, restructuring "while we're here", touching adjacent code — are disallowed.

**Hard cap: ~100 lines including the test.** If the fix grows past that, stop. Classify REPRODUCED+UNFIXED with notes describing what a fuller fix would entail. A small reviewable diff is worth more than a sprawling one.

### Verification

Run, in this order:

1. `vendor/bin/phpcs <changed-files>` — run as soon as the new test passes, on the modified source and test files only. WordPress core enforces phpcs cleanliness; failing it blocks merge. Run early so any style fixes happen before the broader checks.
2. The broader test group the new test lives in (e.g. `vendor/bin/phpunit --group dependencies` for script-loader tests). Confirm zero regressions.
3. For bugs that surface through a concrete admin URL or front-end page: end-to-end verify through that real entry point (browser via Playwright MCP + mu-plugin). A unit test that synthesizes the call sequence can pass while the real lifecycle still misbehaves.

### Critical review

Before committing, review your own diff adversarially — as if reviewing a stranger's PR. Ask:

- Does the change exceed the minimum needed to fix the ticket? Strip any drift.
- Does the test fail without the fix and pass with it, *and* exercise the surface the bug actually occurs on (not a synthesized analogue)?
- Are there assumptions in the fix that aren't load-bearing for the test? Are there callers/contexts that could rely on the prior behavior?
- Did running phpcs / the regression group / end-to-end verification reveal anything you glossed over?
- What would you push back on if a teammate sent this PR?

Address what you find. If a concern can't be resolved within scope, capture it in the report's `notes` field rather than expanding the diff.

## Phase D — Commit and report

Commit on the `trac-<ticket>/<slug>` branch with a WP-style message:

```
<Component>: <imperative summary>.

<2-4 paragraphs explaining the bug, the fix, and any subtlety>.

See #<ticket>.
```

Stage files explicitly (`git add <file1> <file2>`). Never `git add -A` — `.envlite/` and other generated artifacts must not be committed.

Produce the final report as the last message of the conversation, 250 words max:

```
classification:  <REPRODUCED+FIXED | REPRODUCED+UNFIXED | NOT-REPRODUCIBLE | INCONCLUSIVE>
worktree:        <absolute path>
branch:          trac-<ticket>/<slug>  (commit <sha>)
root cause:      <one sentence | n/a>
repro:           <exact command/URL/recipe>
repro evidence:  <"Ticket reports X; repro produces Y; X ≈ Y because Z" | n/a>
fix:             <one sentence | n/a>
verification:    <command + observed result, OR manual recipe + observed result>
test:            <path to test file | waiver: <reason>>
files changed:   <list | none>
notes:           <≤3 lines on edge cases, surprises, reviewer caveats>
```

## Additional resources

- `references/repro-strategies.md` — detailed phpunit / qunit / Playwright MCP guidance, including WP test conventions, action-firing patterns, output capture via `get_echo`, ticket-snippet sanity checks (re-entrancy, broken samples), mu-plugin + browser end-to-end repro pattern, escalation rules, and probe technique for NOT-REPRODUCIBLE evidence.
- `references/worked-example.md` — full walkthrough of Trac #50040 (datepicker footer localization) from setup through report, including the critical-reading-of-comments lesson.
