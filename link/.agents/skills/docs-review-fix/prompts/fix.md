# Fix subagent prompt — Opus, parallel, one per file, runs in a worktree

Variables to interpolate before dispatch:
- `{{FILE}}` — repo-relative path to the doc to edit (ONLY this file)
- `{{SLUG}}` — slug for this file (matches worktree name and report file)
- `{{FINDINGS_JSON}}` — JSON array of findings from `gate/dispatch.json` for this file
- `{{WORKTREE_PATH}}` — absolute path to the worktree you're already inside
- `{{REPORT_PATH}}` — absolute path to write your fix-report JSON to (`$JOB_DIR/fix-reports/<slug>.json`)
- `{{BRANCH_NAME}}` — `docs-fix/<slug>`; you are already on this branch

---

You are fixing documentation defects in **one file**. You are inside a git worktree, on a dedicated branch. Edit, verify, commit. Skip anything that would require touching other files.

## Hard rules — never violate

1. **Edit ONLY `{{FILE}}`.** No other file. Not even `package.json`, not even a sibling README.
2. **Any finding that requires editing other files: mark `status: requires-cross-file` and SKIP it.** Do not edit. Do not "just this once." These get handled by a separate cross-cutting pipeline.
3. **Re-verify each finding after editing** using its `verification` step. If verification fails:
   - **Roll back that single finding's edits** (use git stash + selective restore, or re-edit by hand).
   - Mark that finding `status: verification-failed`, record the original verification output in `notes`.
   - **Keep the other finding fixes.** Per-finding rollback, not all-or-nothing.
4. **Commit with `--no-verify`.** This pipeline only touches markdown files; pre-commit hooks (lint-staged, prettier, etc.) are infrastructure friction here, not real checks. Skipping them is the established policy for this pipeline.

## File to fix
`{{FILE}}`

## Findings (from gate/dispatch.json)
```json
{{FINDINGS_JSON}}
```

## Workflow

1. **Read `{{FILE}}`** — full file. Note the line numbers in the findings may have drifted; locate the actual text.
2. **For each finding, in order:**
   a. Apply the edit per `fix_sketch`. Use judgement — `fix_sketch` is a hint, not a script.
   b. Re-verify with the finding's `verification` step. Confirm the defect is gone AND the surrounding area still makes sense.
   c. On failure: roll back just that finding's edit; mark `verification-failed`.
   d. On cross-file requirement discovered mid-fix: roll back; mark `requires-cross-file`.
3. **Commit** the surviving fixes to `{{BRANCH_NAME}}` with `git commit --no-verify`. Single commit per worktree, message format:
   ```
   docs: fix {{FILE}}
   
   - <finding 1 short description>
   - <finding 2 short description>
   ...
   ```
4. **Write the fix report** to `{{REPORT_PATH}}`:

```json
{
  "file": "{{FILE}}",
  "worktree": "{{WORKTREE_PATH}}",
  "branch": "{{BRANCH_NAME}}",
  "commit": "<full sha or empty string if nothing was committed>",
  "findings": [
    {
      "category": "<finding category>",
      "location": "<finding location>",
      "status": "fixed | verification-failed | requires-cross-file | invalidated",
      "notes": "What you actually did. For verification-failed, the verification output. For requires-cross-file, what other file(s) would need editing. For invalidated, why on closer inspection it wasn't real."
    }
  ]
}
```

## Edge cases

- **Finding turned out to be wrong on closer inspection** — mark `status: invalidated` with explanation. Don't edit.
- **Fix touches a code block that's a copy of source from elsewhere** — if the canonical fix is to update the source file, that's cross-file → skip. If the doc is intentionally showing a snippet that differs (e.g., trimmed for clarity), prefer keeping it as-is and mark `invalidated`.
- **Multiple findings overlap on the same lines** — apply them together, verify together. If one fails, decide carefully which to roll back.

## If every finding fails

If you commit nothing (every finding ended up `verification-failed`, `requires-cross-file`, or `invalidated`), set `"commit": ""` in the report. The orchestrator will know to exclude this branch from consolidation.

## Final message

State:
- Report path written
- Commit SHA (or "no commit" if nothing landed)
- Counts: fixed / verification-failed / requires-cross-file / invalidated
- Anything unusual the orchestrator should know
