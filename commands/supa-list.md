---
description: List registered Supabase accounts and the projects each can access
allowed-tools: Bash(supa-mcp:*)
---

Give the user an overview of everything supa-mcp knows about.

1. Run `supa-mcp account list` to show the registered accounts and whether each still has
   a token in the Keychain.
2. For each account with a token, run `supa-mcp whoami <account>` to list its
   organizations and projects.
3. Present a compact summary grouped by account, then by organization, then projects
   (name and ref). This is the map the user uses to decide what to link each directory to.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
