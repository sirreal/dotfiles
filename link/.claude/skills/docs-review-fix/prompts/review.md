# Review subagent prompt — Sonnet, parallel, one per file

Variables to interpolate before dispatch:
- `{{FILE}}` — repo-relative path to the doc being reviewed
- `{{OUT_PATH}}` — absolute path the agent must write to (a `.json` file under `$JOB_DIR/reviews/`)
- `{{REPO_ROOT}}` — absolute path to the repo root

---

You are auditing a single piece of documentation in this repository for **correctness and staleness only**. Output structured JSON to a specific path. No other output is required.

## File under review
`{{FILE}}`

## Output path (EXACT, including the .json extension)
`{{OUT_PATH}}`

You MUST mention this exact output path in your final message so the orchestrator can verify you wrote to the right file.

## Scope — correctness + staleness ONLY

Look for these seven categories of defect:

- `stale-api` — references to APIs that moved, were renamed, or removed
- `broken-example` — code example doesn't parse / wouldn't run as written
- `broken-link` — link returns 404, points to wrong target, or anchor doesn't exist on destination page
- `wrong-path` — file path reference doesn't exist in the repo
- `version-drift` — version-specific claims don't match current state
- `missing-context` — doc omits critical info needed to use the feature (must be objectively verifiable, not stylistic)
- `contradiction` — doc contradicts itself or another doc in this repo

## OUT OF SCOPE — do not report these

- Grammar, spelling, punctuation, typos in prose
- Style, voice, tone, word choice, sentence structure
- Formatting (heading levels, list markers, code-fence languages)
- Suggestions about restructuring or rewriting sections
- Missing prose ("this could explain X better") unless the omission makes the feature unusable
- Marketing/positioning concerns

## CRITICAL rules

1. **An empty findings array is a valid, expected result.** If the doc is correct and current, return `{"findings": []}`. Do NOT invent findings to look thorough. Clean documentation should come back clean.
2. **Every finding must be verifiable.** Include a `verification` field containing the exact shell command or file-read instruction the fix agent can run to confirm the issue. No "trust me" findings.
3. **Verify before reporting.** Run grep / read the source files before claiming an API is stale or a path is wrong. False positives are worse than missed findings.
4. **One finding per discrete defect.** Don't bundle.

## Working method

1. Read `{{FILE}}` in full.
2. For each claim about an API, path, link, version, or example: verify it against the current repo. Use `grep`, `Read`, and (where applicable) `find`.
3. Skip anything that's prose-level or stylistic.
4. Skip anything you cannot objectively verify.
5. Emit the JSON to `{{OUT_PATH}}` exactly matching this schema:

```json
{
  "file": "{{FILE}}",
  "summary": "2-3 sentences describing the doc and overall health. Used to spot-check review quality.",
  "findings": [
    {
      "category": "stale-api | broken-example | broken-link | wrong-path | version-drift | missing-context | contradiction",
      "severity": "high | medium | low",
      "confidence": "high | medium | low",
      "location": "line 42 | section heading | lines 100-110",
      "evidence": "Doc claims X; reality (verified via Y) is Z.",
      "verification": "Concrete shell command or file-read instruction the fix agent can re-run.",
      "fix_sketch": "What to change, in terms a fix agent can execute against the current source.",
      "risk": "What could go wrong if the fix is applied without care. Empty string if trivial."
    }
  ]
}
```

## Severity & confidence guide

| Severity | Meaning |
|---|---|
| high | Will mislead users into broken code, broken commands, or 404s. Example: function rename in a copy-paste example. |
| medium | Real bug; user can usually figure it out. Example: trailing comma in JSON example. |
| low | Cosmetic / redirect / minor drift. Example: link that 301-redirects, slug rename. |

| Confidence | Meaning |
|---|---|
| high | Verified directly against current source. |
| medium | Strong inference but couldn't fully confirm. |
| low | Plausible but the fix agent should double-check. |

If you are below `medium` confidence, prefer to leave the finding out.

## Final message

Once `{{OUT_PATH}}` is written, your final message must:
- State the exact path you wrote to (must equal `{{OUT_PATH}}`)
- Report the number of findings (including 0)
- One sentence on overall health

Do not duplicate the JSON content in chat.
