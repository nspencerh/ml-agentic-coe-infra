---
name: tu-gh-pr-title
description: "Prepares GitHub pull request titles for Transurban organization-owned repositories, following specific formatting rules. Use this skill when creating a pull request via the `gh` CLI or the GitHub MCP server to ensure compliance with title conventions like `<type[(scope)]!><optional ':' and optional space><sentinel><JIRA-KEY|NO-REF><sentinel><optional text>`."
---

# Transurban GitHub PR Title Guidelines

This document outlines the rules for formatting GitHub pull request titles for repositories owned by the Transurban organisation. Adhering to these guidelines is crucial for maintaining a clean and searchable commit history.

This skill should be used when creating a PR either using `gh` CLI or the Github MCP server.

## Title Format

The expected (relaxed) format for a pull request title is as follows:

`<type[(scope)]!><optional ':' and optional space><sentinel><JIRA-KEY (e.g., ABC-123) OR NO-REF><sentinel><optional text>`

### Components

*   `<type>`: The type of change (e.g., `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`).
*   `[(scope)]`: An optional scope describing the area of the codebase affected.
*   `!`: An optional indicator of a breaking change.
*   `<sentinel>`: A single character from the allowed set to delimit parts of the title.
*   `<JIRA-KEY>`: The relevant Jira issue key (e.g., `ABC-123`).
*   `NO-REF`: Used when there is no associated Jira issue.
*   `<optional text>`: A brief description of the change.

### Allowed Sentinels

The following characters are allowed as sentinels to separate the components of the title:

*   ` ` (space)
*   `/`
*   `:`
*   `[`
*   `]`
*   `(`
*   `)`

### Forbidden Shapes

To ensure consistency, the following patterns are **not** allowed:

*   Double space before the Jira key (e.g., `chore  ABC-123 helo-there`).
*   A colon immediately followed by the Jira key in parentheses (e.g., `feat:(ABC-123)helo-there`).

## Examples

### Valid Examples

*   `chore(parser)(ABC-123) helo-there`
*   `chore(parser):ABC-123:awdawdawd`
*   `feat![ABC-123] hello-there`
*   `chore(parser)! NO-REF update pipelines`
*   `feat: [no-ref] tweak CI`

### Invalid Examples

*   `chore  ABC-123 helo-there` (Reason: Double space before the Jira key)
*   `feat:(ABC-123)helo-there` (Reason: Forbidden `:(KEY)` shape)
