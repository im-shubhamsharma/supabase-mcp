---
description: Open this directory's linked Supabase project in the dashboard
allowed-tools: Bash(supa-mcp:*)
---

The user wants to jump to the Supabase dashboard for whatever project this directory is
linked to. Any hint from the user (e.g. a non-default server name): $ARGUMENTS

1. Run `supa-mcp open` (add `--name <server>` if the user is pointing at a non-default
   server key). It opens `https://supabase.com/dashboard/project/<ref>` using the OS opener,
   or prints the URL if none is available.
2. If it fails because the directory isn't linked, tell the user to run `/supa-link` first.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
