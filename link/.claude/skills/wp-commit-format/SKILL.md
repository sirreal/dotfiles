---
name: wp-commit-format
description: This skill should be used when the user asks about "WordPress commit message format", "WP core commit", "format commit message for WordPress", "WordPress commit guidelines", or "core commit message". Provides official formatting guidelines for WordPress core commit messages.
---

# WordPress Core Commit Message Format

This skill documents the official formatting guidelines for WordPress core commit messages.

## Message Structure

```
Component: Brief summary.

Longer description with more details, such as a `new_hook` being introduced with the context of a `$post` and a `$screen`.

More paragraphs can be added as needed.

Developed in {GitHub PR URL}.

Follow-up to [12345], [67890].

Props person, another.
Fixes #12345. See #67890.
```

## Brief Summary (First Line)

- Must be one line, no line breaks
- Aim for ~50 characters, max 70
- Prefix with component/focus of the change (from Trac ticket component, unless it's "General")
- The list of valid components is at the end of this document
- Use imperative mood: "Add feature" not "Adds feature" or "Added feature"
- Must end with a period

## Description

- Keep brief - only include essential details
- Separated from summary by a blank line
- Describe the _what_ and _why_ (the diff shows _how_)
- The description is an _overview_ - present relevant information but avoid excessive detail
- Informed by both the PR and the Trac ticket
- Can be multiple paragraphs separated by blank lines, but prefer fewer
- Do NOT manually wrap lines
- Code/hooks in backticks: `function_name()`, `hook_name`
- Each sentence should begin with capital letter and end with period

## Developed In Line

- Add `Developed in {PR URL}.` at the end of the description
- Must end with a period
- Must be preceded by a blank line
- Comes BEFORE Follow-up to line (if present)
- Must be followed by a blank line

## Follow-up To Line (Optional)

- Add `Follow-up to [12345], [67890].` if this change relates to previous changesets
- Format changeset numbers as `[123]` (square brackets)
- Comes AFTER Developed in line
- Must be preceded by a blank line
- Must be followed by a blank line before Props

## Props Line

- Give props to all contributors: patches, code suggestions, design, testing, reporting
- Format: `Props username1, username2.`
- No `@` before usernames
- No colon after "Props"
- Separate usernames with comma + space
- Must end with a period
- Use WordPress.org usernames (check Trac for correct usernames)

## Ticket References

- On their own line below Props
- `Fixes #12345.` - closes the ticket
- `See #12345.` - references without closing
- Multiple tickets: `Fixes #123, #456. See #789.`

## Valid Components

The following components are the **only** valid component WordPress core commit messages (from Trac).

- Administration
- AI
- Bootstrap/Load
- Build/Test Tools
- Bundled Theme
- Cache API
- Comments
- Cron API
- Customize
- Database
- Date/Time
- Editor
- Export
- External Libraries
- Feeds
- Filesystem API
- Formatting
- General
- Help/About
- HTML API
- HTTP API
- I18N
- Import
- Interactivity API
- Mail
- Media
- Networks and Sites
- Options, Meta APIs
- Permalinks
- Plugins
- Posts, Post Types
- Privacy
- Query
- REST API
- Script Loader
- Security
- Site Health
- Sitemaps
- Taxonomy
- Themes
- Toolbar
- Upgrade/Install
- Users
- XML-RPC

**Note:** "General" is listed for reference but should not be used as a prefix (see below).

## Things to Avoid

- Don't use `props` anywhere except the Props line
- Don't use hashtag + numbers except for Trac ticket references
- Don't manually wrap description lines
- Don't include time estimates or scheduling language
- Don't use the component prefix if the Trac component is "General"
