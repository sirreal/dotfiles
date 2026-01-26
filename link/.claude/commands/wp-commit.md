---
description: Generate a WordPress core commit message from a GitHub PR
allowed-tools:
  - Bash(~/.claude/scripts/wp-trac-ticket.php:*)
  - Bash(~/.claude/scripts/wp-trac-changeset.php:*)
  - Bash(gh pr view:*)
  - Skill(wp-commit-format)
argument-hint: [pr-number]
---

# WordPress Commit Message Generator

Generate a WordPress core commit message from a GitHub PR and its linked Trac ticket.

You _must_ use the `wp-commit-format` skill to ensure the commit message adheres to WordPress core standards!

## Context

- If a PR number is provided as `$1`, use that. Otherwise omit it from `gh` commands to use the current branch's PR.

## Instructions

1. **Get the PR information:**

   - Fetch PR details using:
     ```sh
     gh pr view [pr-number] --json title,body,number,url --template '{{.title}}
     ---
     PR Number: {{.number}}
     PR URL: {{.url}}
     ---
     {{.body}}'
     ```
   - The PR information should help inform the commit message.

2. **Extract the Trac ticket:**

   - Look in the PR description for a line starting with `Trac ticket: `
   - The ticket URL may be a markdown link `[text](url)` or plain text URL
   - Extract the ticket number from the URL (e.g., `https://core.trac.wordpress.org/ticket/64419` → `64419`)
   - If no Trac ticket is found, ask the user for one

3. **Fetch Trac ticket details:**

   - Use the script: `~/.claude/scripts/wp-trac-ticket.php <ticket-number>` to look up the ticket details
   - Use `component` for the commit message prefix, but NOT if it's "General" (omit the prefix in that case)
   - Use the ticket summary and description to help form the commit message
   - Look for related ticket references (#12345) in the description
   - Fetch those related tickets using `~/.claude/scripts/wp-trac-ticket.php <ticket-number>` to understand how they're related
   - Include related tickets as `See #...` references in the commit message
   - Reference related tickets in the description if appropriate to explain context
   - Note any changeset references found (see step 4)

4. **Discover referenced changesets:**

   Changesets may appear as `r12345` or `[12345]` (e.g., "reverts r58123", "follow-up to [58123]").

   Collect changeset references from:
   - The PR description
   - The linked Trac ticket
   - Related tickets discovered in step 3

5. **Explore discovered changesets:**

   For each changeset found, look it up using: `~/.claude/scripts/wp-trac-changeset.php <changeset-number>`

   Use changeset information to understand relationships:
   - What the original change did (for reverts or follow-ups)
   - Related tickets that may need `See #...` references
   - Context that should be mentioned in the commit message description

6. **Get props from PR comments:**

   - Fetch the props comment from the PR using:
     `gh pr view [pr-number] --comments | rg "Use this line as a base for the props" -A3`
   - Extract the props list from the line starting with `Props `

7. **Generate the commit message:**

   - Follow the WordPress commit message format guidelines above

## Output

Output ONLY the commit message text, properly formatted and ready to copy. Do not include any other commentary or explanation. Use a markdown code block so it's easy to copy.
