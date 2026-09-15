---
description: Guided first-time setup — add a Supabase account (if needed) and link this directory
allowed-tools: Bash(supa-mcp:*)
---

The user wants to get supa-mcp set up for this directory in one go. Any hint from the user:
$ARGUMENTS

`supa-mcp init` walks through adding an account (only if none exist yet) and linking the
current directory, reusing the same prompts as `/supa-add` and `/supa-link`. Prefer running
it directly in the user's terminal rather than trying to drive every sub-step yourself,
since it needs a real terminal for the hidden token prompt and any interactive picks:

```
supa-mcp init
```

Tell the user to run that command themselves. While it runs:

1. If they have no accounts yet, it asks for an account name, then prompts for the PAT
   (hidden input, goes straight to the Keychain — never ask them to paste it in chat).
   They can create a token at https://supabase.com/dashboard/account/tokens.
2. If they have exactly one account, it links this directory to it automatically and
   prompts for which project. If they have more than one account, it asks which one this
   directory belongs to first.
3. Access mode defaults to read-only. If the user wants read-write from this directory,
   tell them to link again afterward with `/supa-link ... --write`, or run
   `supa-mcp switch --write`.

After it finishes, confirm with `supa-mcp status --json`, then remind them to start a
fresh Claude Code session in this directory (accepting the trust and Keychain prompts) to
connect.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
