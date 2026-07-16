# supa-mcp

Per-project Supabase MCP switcher for Claude Code, for people who work across several
Supabase projects on more than one account.

Open Claude Code in a project directory and its Supabase MCP connects to exactly that
project's database, on the correct account, read-only by default. Tokens stay encrypted in
the macOS Keychain and never touch disk.

## The problem

The default Supabase MCP uses OAuth and connects one organization at a time. If you have a
personal account with three projects and a company account with two organizations, you end
up logging out and back in to switch, and a session open in a company project can still be
pointed at your personal account.

## How it works

- A Supabase Personal Access Token (PAT) is per account, not per organization. One token
  reaches every organization and project in that account, so a personal login and a company
  login are two tokens total.
- `supa-mcp link` writes a `.mcp.json` into the current project directory that pins one
  project (`project_ref`) and names the account it belongs to.
- Claude Code auto-loads `.mcp.json` from the directory it starts in, so the right project
  connects automatically. No manual switching.
- At every connection, Claude Code runs `supa-mcp headers --account <name>`, which reads
  the token from the Keychain in memory and returns the `Authorization` header. This uses
  Claude Code's `headersHelper`, so no token is ever written into `.mcp.json`.

A generated `.mcp.json` looks like this. It holds no secret, so it is safe to commit:

```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=abcd1234&read_only=true",
      "headersHelper": "supa-mcp headers --account company"
    }
  }
}
```

## Security

- Tokens live only in the macOS login Keychain, service name `supa-mcp`, encrypted at rest
  and visible in Keychain Access.app.
- `.mcp.json`, the registry, environment variables, and git never hold a token.
- New links are read-only by default (`read_only=true`). Writes need an explicit `--write`.
- The first MCP connection shows a one-time macOS Keychain prompt for `supa-mcp`. Choose
  "Always Allow" to make it silent afterward.

## Requirements

macOS, plus `jq`, `curl`, and `security` (the last two ship with macOS; install `jq` with
`brew install jq`).

## Install

### As a Claude Code plugin (recommended)

Add this repository as a marketplace and install the plugin from inside Claude Code. This
also wires up the `/supa-*` slash commands and the skill:

```
/plugin marketplace add im-shubhamsharma/supabase-mcp
/plugin install supa-mcp@supa-mcp
```

Then put the CLI on your PATH (once per machine):

```
supa-mcp install
```

To pick up later changes, run `/plugin marketplace update supa-mcp` inside Claude Code.

### As a plain CLI from a clone

```
git clone https://github.com/im-shubhamsharma/supabase-mcp.git
cd supabase-mcp
./install.sh          # symlinks supa-mcp into ~/.local/bin
```

Either way, make sure `~/.local/bin` is on your PATH (add
`export PATH="$HOME/.local/bin:$PATH"` to your `~/.zshrc` if needed). Run
`supa-mcp doctor` to check.

Tokens never travel with the repo: they live only in each machine's macOS Keychain, so on a
new machine you register that machine's own accounts with `supa-mcp account add <name>`.

## Quick start

```
# 1. Register each account (prompts for the token, hidden input, stored in the Keychain)
supa-mcp account add personal
supa-mcp account add company

# 2. See what a token can reach
supa-mcp whoami company

# 3. In a project directory, link it to the right account and project
cd ~/work/company-app
supa-mcp link --account company --project-ref abcd1234

# 4. Start a fresh Claude Code session in that directory. Accept the trust and
#    Keychain prompts. The Supabase MCP is now connected to that project.
```

Inside Claude Code you can drive the same steps with `/supa-add`, `/supa-link`,
`/supa-status`, `/supa-list`, and `/supa-unlink`.

## Commands

| Command | Purpose |
| --- | --- |
| `supa-mcp account add <name>` | Store a PAT in the Keychain (hidden prompt). |
| `supa-mcp account list [--json]` | List registered accounts. |
| `supa-mcp account remove <name>` | Delete an account and its token. |
| `supa-mcp whoami <account> [--json]` | Show the orgs and projects a token can see. |
| `supa-mcp projects <account> [--json]` | List an account's projects. |
| `supa-mcp link --account <n> --project-ref <ref> [--write] [--name <server>]` | Write `./.mcp.json`. |
| `supa-mcp status [--json] [--no-verify]` | Show and verify this directory's binding. |
| `supa-mcp unlink [--name <server>]` | Remove the server from `./.mcp.json`. |
| `supa-mcp doctor` | Check dependencies and current-directory status. |
| `supa-mcp install [dir]` | Put `supa-mcp` on PATH. |

## The wrong-account guard

`supa-mcp status` reads the directory's `.mcp.json` and checks live that the pinned
`project_ref` actually belongs to the linked account. If it does not, it reports
`account_verified: false` so you catch a mislinked directory before you run anything
against it.

## Limitations

- macOS only for now. Linux and Windows are a planned follow-up (swap `security` for
  `secret-tool` or Credential Manager).
- One connection per directory by default. You can add more with `--name` (for example a
  separate staging project in the same repo).
