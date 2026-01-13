---
description: Generate a WordPress core commit message from a GitHub PR
allowed-tools:
  - Bash(gh pr view:*)
  - mcp__plugin_github_github__pull_request_read
  - mcp__fetch__fetch(https://core.trac.wordpress.org/ticket/*)
  - mcp__fetch__fetch(https://core.trac.wordpress.org/changeset/*)
  - fetch(https://core.trac.wordpress.org/ticket/*)
  - fetch(https://core.trac.wordpress.org/changeset/*)
argument-hint: [pr-number]
context: fork
---

# WordPress Commit Message Generator

Generate a WordPress core commit message from a GitHub PR and its linked Trac ticket.

## Context

- Current branch PR number: !`gh pr view --json number --jq .number 2>/dev/null || echo "none"`

## Instructions

1. **Get the PR information:**
   - If a PR number is provided as `$1`, use that
   - Otherwise, use the current branch PR number from context above
   - If no PR is found, ask the user for one
   - Fetch full PR details with: `gh pr view <number> --json number,title,body,url`

2. **Extract the Trac ticket:**
   - Look in the PR description for a line starting with `Trac ticket: `
   - The ticket URL may be a markdown link `[text](url)` or plain text URL
   - Extract the ticket number from the URL (e.g., `https://core.trac.wordpress.org/ticket/64419` → `#64419`)
   - If no Trac ticket is found, ask the user for one

3. **Fetch Trac ticket details:**
   - Fetch the Trac ticket in TSV format: `https://core.trac.wordpress.org/ticket/{number}?format=tab`
   - TSV columns: id, summary, reporter, owner, description, type, status, priority, milestone, component, version, severity, resolution, keywords, cc, focuses
   - Use `component` for the commit message prefix, but NOT if it's "General" (omit the prefix in that case)

4. **Get props from PR comments:**
   - Fetch PR comments with: `gh pr view <number> --comments`
   - Look for the props-bot comment containing "Core Committers: Use this line as a base for the props"
   - Extract the props list from the line starting with `Props `

5. **Generate the commit message following WordPress guidelines:**

### Format

```
Component: Brief summary.

Longer description with more details, such as a `new_hook` being introduced with the context of a `$post` and a `$screen`.

More paragraphs can be added as needed.

Developed in {GitHub PR URL}.

Props person, another.
Fixes #{ticket}. See #{related}, #{tickets}.
```

### Guidelines

**Brief Summary (first line):**
- Must be one line, no line breaks
- Aim for ~50 characters, max 70
- Prefix with component/focus of the change
- Use imperative mood: "Add feature" not "Adds feature" or "Added feature"
- Must end with a period

**Description:**
- Separated from summary by a blank line
- Describe the *what* and *why* (the diff shows *how*)
- Can be multiple paragraphs separated by blank lines
- Do NOT manually wrap lines
- Code/hooks in backticks: `function_name`, `hook_name`
- Each sentence should begin with capital letter and end with period

**Developed in line:**
- Add `Developed in {PR URL}.` at the end of the description
- Must be preceded by a blank line
- Must be followed by a blank line before Props

**Props:**
- Give props to all contributors: patches, code suggestions, design, testing, reporting
- Format: `Props username1, username2.`
- No `@` before usernames
- No colon after "Props"
- Separate usernames with comma + space
- Must end with a period
- Use WordPress.org usernames (check Trac for the correct usernames)

**Ticket References:**
- On their own line below Props
- `Fixes #12345.` - closes the ticket
- `See #12345.` - references without closing
- Multiple tickets: `Fixes #123, #456. See #789.`

### Things to Avoid

- Don't use `props` anywhere except the Props line
- Don't use hashtag + numbers except for Trac ticket references
- Don't manually wrap description lines
- Don't include time estimates or scheduling language

## Output

Output ONLY the commit message text, properly formatted and ready to copy. Do not include any other commentary or explanation. Use a markdown code block so it's easy to copy.
