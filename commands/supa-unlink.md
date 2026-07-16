---
description: Remove the Supabase MCP server from this directory's .mcp.json
allowed-tools: Bash(supa-mcp:*)
---

The user wants to unlink the current directory. Optional server name: $ARGUMENTS

1. Run `supa-mcp status --no-verify` first so the user can see what is currently linked.
2. Remove it:

   ```
   supa-mcp unlink
   ```

   Add `--name <server>` if the user wants to remove a specific server key rather than the
   default `supabase`.
3. Confirm what was removed. This edits only `.mcp.json`; it does not touch the stored
   token. The account and its token stay in the Keychain for other projects.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
