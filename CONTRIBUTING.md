# Contributing to supa-mcp

Thanks for your interest! Issues and pull requests are welcome.

## Ground rules

- **Never include real secrets.** No Personal Access Tokens, real `project_ref`s, org names,
  or account names in issues, PRs, commits, or test fixtures.
- Keep the CLI a single, dependency-light Bash script (`bin/supa-mcp`). The only runtime
  dependencies are `jq`, `curl`, and an OS keychain tool (`security` / `secret-tool`).
- **Target Bash 3.2.** macOS still ships Bash 3.2, so avoid Bash 4+ features (associative
  arrays, `${var,,}`, `mapfile`, etc.).

## Development setup

```
git clone https://github.com/im-shubhamsharma/supabase-mcp.git
cd supabase-mcp
brew install jq shellcheck bats-core     # macOS
# or: sudo apt-get install -y jq shellcheck bats   # Debian/Ubuntu
```

## Running the checks

```
shellcheck -s bash bin/supa-mcp install.sh hooks/session-start.sh tests/stubs/*
bats tests/
```

Both run in CI (Linux + macOS) on every push and pull request. Please keep them green.

## Tests

Tests live in `tests/*.bats` and use stubs in `tests/stubs/` that fake the keychain
(`security`, `secret-tool`) and the Supabase API (`curl`). This means the suite touches
**no real Keychain and makes no network calls** — it is safe to run anywhere.

If you add a feature, add a test for it. The stubs recognize fixture tokens `TOKEN_personal`
and `TOKEN_company` (and `BADTOKEN` for the invalid-token path); see `tests/test_helper.bash`
and `tests/stubs/curl` to extend the fixtures.

## Good first areas

- A Windows Credential Manager keychain backend (the abstraction is in `kc_*` functions).
- More tests and edge cases.
- Docs improvements.

## Pull requests

- Keep changes focused; one topic per PR.
- Update `CHANGELOG.md` under a suitable heading.
- Make sure `shellcheck` and `bats` pass locally.
