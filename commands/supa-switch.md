---
description: Re-point the current directory's Supabase binding to a different project or account
allowed-tools: Bash(supa-mcp:*)
argument-hint: [project or account hint]
---

The user wants to switch which Supabase project this directory is linked to. Any
hint from the user: $ARGUMENTS

Steps:

1. Show the current binding first so the user sees what will change:

   ```
   supa-mcp status --no-verify --json
   ```

   If it reports `linked: false`, this directory is not linked yet — tell the user to run
   `/supa-link` instead and stop.
2. Decide the target. `switch` keeps the current account unless you pass a new one, so:
   - To move to another project on the **same** account, you only need a new `--project-ref`.
     List the account's projects with `supa-mcp projects <account> --json` and present a
     short numbered list (name, ref, org) to choose from.
   - To move to a **different** account, pass `--account <name>` as well (and pick a project
     from that account).
3. Access mode is preserved from the current binding. Only pass `--write` if the user
   explicitly wants to switch to read-write, or `--read-only` to force read-only.
4. Apply the switch:

   ```
   supa-mcp switch --project-ref <ref> [--account <name>] [--write] --json
   ```

   (add `--name <server>` if switching a non-default server key)
5. Report the change, then remind the user they must start a fresh Claude Code session in
   this directory for the new binding to take effect.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
