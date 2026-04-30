---
name: mcp-auth-guide
description: Guidance for authentication with OAuth-enabled MCP servers, specifically GitHub and Atlassian Rovo. Trigger this skill when an MCP server login or authentication failure occurs.
---

# MCP Authentication Guide

This skill provides instructions for authenticating with OAuth-enabled MCP servers, currently including GitHub and `atlassian-rovo-mcp-server`.

## General OAuth Authentication

For most OAuth-enabled MCP servers, follow these steps:

1.  Run the command `/mcp auth` in the Gemini CLI.
2.  Choose the corresponding MCP server from the list.
3.  A browser web page will open for you to complete the login process.

## GitHub Remote MCP (Personal Access Token)

If you prefer to use a Personal Access Token (PAT) for the GitHub Remote MCP, you must update your `.gemini/settings.json` file.

Add or update the `"github"` entity and the `"inputs"` array as follows:

```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer $GITHUB_MCP_PAT"
    }
  }
}
```
The environment variable GITHUB_MCP_PAT need to be set with Github PAT token. For now, Gemini CLI currently can't work with Github MCP using OAuth because GitHub MCP (Model Context Protocol) server does not support dynamic client registration (DCR), requiring a pre-configured client ID to be provided manually.

## Troubleshooting Authentication Failures

If you encounter an authentication or login failure with any MCP server, remember to check:
- If the `/mcp auth` command has been run recently.
- If your `.gemini/settings.json` configuration is correct for token-based authentication.
