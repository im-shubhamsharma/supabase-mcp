---
name: supabase-mcp
description: Use when the user works across multiple Supabase accounts, organizations, or projects and wants each project directory to connect its Supabase MCP to the correct account and project automatically. Covers switching Supabase MCP connections, "wrong account" problems, and per-project Supabase setup in Claude Code.
---

# supa-mcp: per-project Supabase MCP switcher

## The problem this solves

A user with several Supabase projects across two or more accounts (and multiple
organizations inside an account) cannot keep them straight with the default Supabase MCP,
which uses OAuth and connects one organization at a time. Claude Code open in a company
project can still be pointed at a personal account.

## The model

- Each project directory gets its own `.mcp.json` that pins exactly one Supabase project
  (`project_ref`) and names the account it belongs to.
- Claude Code auto-loads `.mcp.json` from the directory it starts in, so the right project
  connects automatically with no manual switching.
- A Personal Access Token (PAT) is per account, not per organization, so one token reaches
  every organization and project in that account. A user with a personal and a company
  login needs two tokens total.

## Security (state this to the user when relevant)

- Tokens live only in the macOS login Keychain, service name `supa-mcp`, encrypted at rest
  and viewable in Keychain Access.app.
- `.mcp.json` holds no secret. It contains the non-secret `project_ref` and a
  `headersHelper` command. It is safe to commit.
- At every MCP connection Claude Code runs `supa-mcp headers --account <name>`, which reads
  the token from the Keychain in memory and prints the `Authorization` header. Nothing is
  written to disk, env, or git.
- New links are read-only by default (`read_only=true` in the URL). Writes require an
  explicit `--write` at link time.

## Commands (the CLI is `supa-mcp`, installed on PATH)

| Command | Purpose |
| --- | --- |
| `supa-mcp account add <name>` | Store a PAT in the keychain (prompts, hidden input). |
| `supa-mcp account list [--json]` | List registered accounts. |
| `supa-mcp whoami <account> [--json]` | Show the orgs and projects a token can see. |
| `supa-mcp projects <account> [--json]` | List an account's projects (name, ref, org). |
| `supa-mcp branches <account> <ref> [--json]` | List a project's Supabase branches. |
| `supa-mcp link --account <n> --project-ref <ref> [--write]` | Write `./.mcp.json`. |
| `supa-mcp switch [--account <n>] [--project-ref <ref>] [--write]` | Re-point this directory's binding. |
| `supa-mcp status [--json]` | Show and verify this directory's binding. |
| `supa-mcp list [--json] [--verify]` | Every linked directory on this machine. |
| `supa-mcp unlink [--name <server>]` | Remove the server from `./.mcp.json`. |
| `supa-mcp export` / `import [file]` | Move accounts + links between machines (no secrets). |
| `supa-mcp headers --account <name>` | Internal hot path used by `headersHelper`. |
| `supa-mcp doctor` / `supa-mcp install` | Check deps + token health / put `supa-mcp` on PATH. |

## How to drive it

- Prefer the `--json` output of `account list`, `projects`, `branches`, `status`, and `list`
  so you can present clean choices in chat instead of pasting raw tool output.
- Never ask the user to paste a token into the chat, and never pass a token on the command
  line. For adding an account, have the user run `supa-mcp account add <name>` in their own
  terminal so the token stays out of the transcript.
- After a `link` or `switch`, remind the user to start a fresh Claude Code session in that
  directory, and that the first connect shows a trust prompt plus a one-time keychain prompt.
- To move a directory to a different project on the same account, use `supa-mcp switch
  --project-ref <ref>`; only pass `--account` when moving to a different account.
- When a user is unsure whether a directory is on the right account, run `supa-mcp status`.
  An `account_verified` of `false` means the pinned project does not belong to the linked
  account (wrong account); recommend re-linking or `switch`.
- To see everything at once (e.g. "which of my repos points where?"), run `supa-mcp list`.

Cross-platform: the keychain backend is `security` on macOS and `secret-tool` on Linux,
chosen automatically. A SessionStart hook surfaces the current directory's binding on
session start; `supa-mcp statusline` gives a one-line summary for status lines.

The slash commands `/supa-add`, `/supa-link`, `/supa-switch`, `/supa-status`, `/supa-list`,
`/supa-branches`, and `/supa-unlink` wrap these steps.
