---
description: Show and verify which Supabase account and project this directory is linked to
allowed-tools: Bash(supa-mcp:*)
---

Run:

```
supa-mcp status --json
```

Then explain the result in plain language:

- If `linked` is false, say the directory is not linked and offer to run `/supa-link`.
- Otherwise report the account, the `project_ref`, and the mode (read-only or
  read-write), and whether the token is present in the Keychain.
- Read `account_verified` carefully:
  - `true`: confirm the pinned project (`project_name`, `org_name`) really belongs to the
    linked account. This is the all-clear.
  - `false`: warn clearly that the `project_ref` was NOT found under the linked account.
    This is the wrong-account case the user wants to catch. Recommend re-linking with
    `/supa-link`.
  - `unreachable`: the Supabase API could not be reached, so the account could not be
    confirmed live. Report the local details and suggest retrying when online.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once, then
retry.
