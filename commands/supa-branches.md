---
description: List the Supabase branches of a project (for linking to a preview/branch database)
allowed-tools: Bash(supa-mcp:*)
argument-hint: [account] [project-ref]
---

The user wants to see the branches of a Supabase project. Any hint from the user:
$ARGUMENTS

Steps:

1. Determine the account and project ref.
   - If the current directory is linked, `supa-mcp status --no-verify --json` gives you the
     account and `project_ref` to default to.
   - Otherwise ask which account, then list its projects with
     `supa-mcp projects <account> --json` and have the user pick one.
2. List the branches:

   ```
   supa-mcp branches <account> <project-ref> --json
   ```

3. Present them as a short list showing branch name, branch ref (`id`), whether it is the
   default branch, and status. Explain that a Supabase branch has its own project ref, so
   to point this directory at a branch database the user would link/switch to that branch's
   ref, e.g. `supa-mcp switch --project-ref <branch-ref>`.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
