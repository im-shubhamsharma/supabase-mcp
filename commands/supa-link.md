---
description: Link the current project directory to a Supabase account and project (writes .mcp.json)
allowed-tools: Bash(supa-mcp:*)
---

Link the current working directory to the correct Supabase account and project. Any hint
from the user: $ARGUMENTS

Steps:

1. List accounts: `supa-mcp account list --json`. If there are none, tell the user to run
   `/supa-add` first and stop.
2. Decide the account. If the user named one (or there is only one), use it. Otherwise
   ask which account this project belongs to.
3. List that account's projects: `supa-mcp projects <account> --json`. Present them as a
   short numbered list showing project name, organization, and ref. Ask the user to pick
   the project for this directory. If the user already named the exact project, you can
   skip straight to `supa-mcp link --account <account> --project <name> --json` and let it
   resolve the ref for you (it fails clearly if the name is ambiguous or unknown).
4. Access mode is read-only by default, which is the safe choice. Only add `--write` if
   the user explicitly asks to allow writes from this project.
5. Write the config:

   ```
   supa-mcp link --account <account> --project-ref <ref> --json
   ```

   (add `--write` only if requested; add `--name <server>` if the user wants a
   non-default server key, for example a second staging connection in the same repo)
6. Report what was written, then tell the user:
   - This wrote `.mcp.json` in the current directory. It contains no secret (only the
     project ref and a helper command), so it is safe to commit if they want teammates on
     the same setup to share it.
   - They must start a fresh Claude Code session in this directory for the new server to
     load. On first connect they will see a workspace trust prompt and a one-time macOS
     Keychain prompt for `supa-mcp`. Choosing "Always Allow" makes it silent afterward.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
