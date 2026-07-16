# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0]

### Added
- **Linux support.** The keychain layer is now pluggable: macOS uses `security`, Linux uses
  `secret-tool` (libsecret). Override with `SUPA_MCP_KEYCHAIN`.
- **`supa-mcp list`** — a global overview of every directory linked on this machine, with
  automatic pruning of directories whose `.mcp.json` is gone. `--verify` checks each live.
- **`supa-mcp switch`** — re-point the current directory's binding to a different project or
  account without retyping the full `link`.
- **`supa-mcp branches <account> <ref>`** — list a project's Supabase branches (each branch
  has its own ref you can link/switch to).
- **`supa-mcp statusline`** — a compact one-line binding summary for shell/Claude Code
  status lines.
- **`supa-mcp export` / `import`** — move your (non-secret) account and link registry between
  machines. Tokens are never exported; you re-add them per machine.
- **`supa-mcp version` / `--version`**.
- **Token health in `supa-mcp doctor`** — validates each stored token against the API and
  reports the active keychain backend.
- **SessionStart hook** — on session start/resume, surfaces which Supabase account/project
  the current directory is pinned to and nudges you to `/supa-status`. Local-only and fast.
- **Slash commands** `/supa-switch` and `/supa-branches`.
- **Test suite** — `bats` tests with fully mocked keychain and API (no secrets, no network),
  plus `shellcheck` and a GitHub Actions CI matrix on Linux and macOS.
- **Website** at <https://im-shubhamsharma.github.io/supabase-mcp/> gains an animated
  terminal demo, a light/dark toggle, and a comparison table.

### Changed
- Links made by `link`/`switch` are now recorded in `~/.config/supa-mcp/links.json`, and
  removed by `unlink`.

## [0.1.0]

### Added
- Initial release: per-project Supabase MCP switcher for Claude Code (macOS). Per-account
  Personal Access Tokens in the macOS Keychain, per-directory `.mcp.json` with a
  `headersHelper`, read-only by default, and a live wrong-account guard in `status`.
- CLI (`supa-mcp`), Claude Code plugin, five slash commands, and a skill.

[0.2.0]: https://github.com/im-shubhamsharma/supabase-mcp/releases/tag/v0.2.0
[0.1.0]: https://github.com/im-shubhamsharma/supabase-mcp/releases/tag/v0.1.0
