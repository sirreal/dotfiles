---
name: docs-review-fix
description: Use when the user wants to review and fix documentation correctness/staleness across a set of files — broken code examples, stale APIs, wrong file paths, dead links, version drift, contradictions. Operates on READMEs and docs/ markdown. Output is a local branch plus a report. Never opens PRs or issues; never edits prose for grammar/style/voice.
---

# docs-review-fix

## Overview

Six-stage multi-agent pipeline that finds and fixes correctness/staleness bugs in markdown documentation across a file list. A pre-filter drops auto-generated docs; parallel **Sonnet** reviewers find candidate issues; an **Opus** gate validates them and filters noise; parallel **Opus** fixers edit one file each in isolated worktrees; consolidation cherry-picks the verified branches; a final Opus gate audits the integration diff.

**Validated by pilot:** 20 files, 33 dispatched findings, 0 regressions, 0 self-verification failures, 0 merge conflicts (hard-scope rule). See `examples/` for real outputs.

## Hard constraints — never violate

- **No PRs. No issues. Ever.** Output is a local branch + report. The user opens PRs themselves.
- **Correctness & staleness only.** Grammar, spelling, style, voice, formatting are **out of scope** — different tool.
- **One file per fix agent.** Cross-file fixes are deferred — reported in `gate/cross-cutting.json` for separate handling (see "Cross-cutting findings" below).
- **Sonnet reviews, Opus fixes.** Don't swap the model assignment.
- **Branch overwrite protection.** If the target branch exists with uncommitted manual edits, **stop and ask** before overwriting.
- **Empty findings is a valid review result.** Reviewers must not invent findings on clean files. The pilot had 5/20 clean files; over-firing would have wasted Opus budget on hallucinated work.

## When to use

- "Review and fix the docs for X" / "audit our READMEs" / "find stale examples in docs/"
- Quarterly doc-correctness sweeps across a package or section
- After a large refactor that may have left docs referring to old APIs

**Not for:** spelling, prose quality, restructuring, new content. Use a different tool.

## Inputs

Required from the user (or inferable from context):

1. **File list** — a path to a text file with one path per line, OR a glob. Paths relative to repo root.
2. **Target branch name** (default: `docs-review-fix`). Pipeline overwrites it unless it has uncommitted manual edits.

Optional:

- **Job dir** — defaults to `$CLAUDE_JOB_DIR` if set, else `$(mktemp -d)`. Stores all artifacts (reviews, dispatch, fix-reports, final-gate report).

## Pipeline

```
file list
   │
   ▼
[1. pre-filter] ── drop auto-generated READMEs ──► cross-cutting/auto-generated.json
   │
   ▼
[2. review]   N× Sonnet subagents, parallel, one per file
   │           emit reviews/<slug>.json
   ▼
[3. gate]     1× Opus subagent, repo-wide grep/read access
   │           emit gate/dispatch.json, gate/cross-cutting.json, gate/skipped.json
   ▼
[4. fix]      M× Opus subagents, parallel, one per qualifying file
   │           each in its own worktree (EnterWorktree), hard-scoped to one file
   │           emit fix-reports/<slug>.json
   ▼
[5. consolidate]  cherry-pick verified branches into target branch in main repo
   │
   ▼
[6. final gate]   1× Opus subagent, audits integration diff vs main
                  emit final-gate/report.md  (orchestrator writes — subagent's Write is blocked)
   │
   ▼
report + branch handed to user
```

## Stage 1 — pre-filter

For each input path:

1. **Auto-generated detection.** Read the first 50 lines. If the file contains any of:
   - `<!-- START TOKEN`
   - `auto-generated`, `Auto-generated`, `AUTO-GENERATED`, `DO NOT EDIT`
   - `@generated`

   → exclude from review. Append to `gate/cross-cutting.json` under pattern `auto-generated-readme` so the user knows the generator needs fixing instead.

2. **Slug derivation.** Deterministic: replace `/` with `__`, strip `.md` extension.
   - `packages/dataviews/README.md` → `packages__dataviews__README`
   - `docs/getting-started/tutorial.md` → `docs__getting-started__tutorial`

   Use `helpers/slug.sh <path>`.

3. **Validation.** Drop paths that don't exist or aren't tracked by git.

## Stage 2 — review (parallel Sonnet)

Dispatch one Sonnet subagent per surviving file using `prompts/review.md`. Each writes JSON to `$JOB_DIR/reviews/<slug>.json` matching `schemas/review-finding.schema.json`.

**Load-bearing instructions in the prompt — do not edit out:**
- "DO NOT report grammar/spelling/style/voice/formatting."
- "Empty findings array is FINE — DO NOT invent findings."

**Post-validation per review:** check the agent's report mentions the *exact* assigned output path (caught one pilot bug where Sonnet reported `.md` instead of `.json`). If mismatched, re-dispatch once.

Retry budget: 1 retry per file on failure, then mark failed and continue.

## Stage 3 — gate (single Opus, max effort)

One Opus subagent reads every review JSON and has repo-wide grep/read access. Uses `prompts/gate.md`. Emits three files:

- `gate/dispatch.json` — validated medium+/high findings, partitioned by file (no file appears twice). Conforms to `schemas/dispatch.schema.json`.
- `gate/cross-cutting.json` — patterns spanning ≥2 files. Conforms to `schemas/cross-cutting.schema.json`. **Reported only**, not executed here.
- `gate/skipped.json` — files with no qualifying work, with invalidated/demoted findings recorded.

**Load-bearing prompt directives:**
- "Be SKEPTICAL. Most reviewer findings need verification against actual source."
- "Demote findings that are real but low-severity; record them in skipped.json."
- "Detect cross-file patterns — they belong in cross-cutting.json, not dispatch.json."

## Stage 4 — fix (parallel Opus, worktree-per-file)

For each file in `gate/dispatch.json`:

1. **Create a worktree.** Use `EnterWorktree` with `name=<slug>` from a subagent dispatched for this file. Each fix agent runs in its own worktree.
2. **Dispatch the fix agent** using `prompts/fix.md`, passing the slug, file path, and the gate's findings array for that file.

**Load-bearing prompt directives:**
- "Edit ONLY the assigned file."
- "Any finding that requires editing other files: mark status `requires-cross-file` and SKIP it. Do not edit."
- "Re-verify each finding with its `verification` command after editing. On failure, roll back that single finding's edits — keep the others."

Each fix agent commits to a per-worktree branch `docs-fix/<slug>` with `--no-verify` (this pipeline only touches markdown; pre-commit hooks like lint-staged are infra friction here, not real checks) and writes `fix-reports/<slug>.json` matching `schemas/fix-report.schema.json`.

**If every finding in a worktree fails verification:** the branch is excluded from consolidation. Record in fix-report.

## Stage 5 — consolidate

In the main repo:

1. **Branch overwrite check.** If `<target-branch>` exists locally:
   - If working tree clean and HEAD matches an earlier pipeline run → safe to overwrite.
   - If working tree has uncommitted edits OR there are commits not from this pipeline → **STOP and ask the user**. Show the branch state.
2. Create or reset `<target-branch>` from `main` (or current default branch).
3. Cherry-pick each qualifying `docs-fix/<slug>` branch's head commit.
4. Conflict during cherry-pick → record in final report and skip that file. (Should not happen given hard-scope rule; if it does, something violated the rule.)

## Stage 6 — final gate

Dispatch one Opus subagent using `prompts/final-gate.md`. Subagent reads the diff of `<target-branch>..main` and audits each file against the dispatched findings + source.

**Subagent's Write tool is blocked by the harness** on the report path. Have the subagent return the report body as its final message. **Orchestrator writes** `final-gate/report.md` from that body.

Output:
- **Verdict**: ACCEPT / ACCEPT-WITH-NOTES / REJECT
- Per-file audit
- Pilot metrics (counts, resolution rate, regression count)
- Notes for human reviewer

If verdict is REJECT → delete `<target-branch>` and surface the report only. The user fixes whatever the gate flagged before re-running.

## Final deliverable

Hand the user three things:

1. Branch name (`<target-branch>`)
2. `final-gate/report.md` — verdict + per-file audit
3. `gate/cross-cutting.json` — patterns the per-file pipeline can't fix (see "Cross-cutting findings" below)

**Never open PRs. Never file issues.** The user reviews the branch and opens the PR themselves.

## Cross-cutting findings

The gate emits `gate/cross-cutting.json` for patterns spanning two or more files — URL hierarchy renames, org-name changes in external links, an API rename touching many examples, repeated JSON-syntax bugs in a code-block pattern. These are **deliberately not auto-fixed** by this pipeline.

**Why deferred:** the per-file pipeline's zero-conflict guarantee comes from the hard-scope rule (one file per agent, parallel). A coordinated edit touching N files for the same root cause needs the opposite orchestration: one sequential agent applying one recipe across many files. Mixing the two relaxes the guarantee.

**What to do with cross-cutting.json:** for v1, act on it manually. The file lists, per pattern: the affected files (from a verifying grep), an `evidence` field with the detection command, and a `recommended_action`. A typical flow:

1. Pick a pattern.
2. Run the `evidence` grep yourself to confirm the affected file list is current.
3. Apply the `recommended_action` — either by hand, or by dispatching one Opus call per file with hand-scoped instructions, on a separate branch from the per-file fixes.
4. Verify each file the same way the recommended_action describes.

For five patterns from a typical run, manual application is usually faster than building a separate sequential pipeline. If automating becomes worthwhile later, it would be a separate skill (sequential, single-agent, recipe-then-sweep) — not a mode of this one.

## Files in this skill

| File | Purpose |
|---|---|
| `SKILL.md` | This file — orchestration logic |
| `prompts/review.md` | Sonnet review subagent prompt |
| `prompts/gate.md` | Opus gate subagent prompt |
| `prompts/fix.md` | Opus fix subagent prompt |
| `prompts/final-gate.md` | Opus final-gate subagent prompt |
| `helpers/slug.sh` | Deterministic path → slug |
| `helpers/pre-filter.sh` | Detect auto-generated READMEs |
| `schemas/*.schema.json` | JSON Schemas for inter-stage artifacts |
| `examples/` | Real outputs from the pilot — golden samples |

## Pilot metrics (May 2026)

20 files reviewed → 5 clean, 15 with findings. Gate validated 33 / invalidated 1 / demoted ~8 / surfaced 5 cross-cutting patterns. 13 fix agents, 33/33 fixed, 0 regressions, 0 merge conflicts. Branch totaled 13 commits, +95/-110 lines. Final verdict: ACCEPT WITH NOTES.

## Common mistakes

- **Relaxing the hard-scope rule** ("just this one cross-file fix") — destroys the zero-conflict guarantee. The fix agent should mark it `requires-cross-file` and let it land in `gate/cross-cutting.json` for separate handling.
- **Dropping "Empty findings is FINE"** from review prompt — reviewers will hallucinate work on clean files.
- **Skipping the auto-generated pre-filter** — burns Sonnet budget on files that regenerate from source.
- **Letting the final-gate subagent Write the report** — its Write is harness-blocked on that path. Subagent returns content; orchestrator writes.
