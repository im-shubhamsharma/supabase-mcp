# Security Policy

## How supa-mcp handles secrets

- Supabase Personal Access Tokens are stored **only** in the OS keychain — the macOS login
  Keychain (`security`) or Linux libsecret (`secret-tool`), under the service name
  `supa-mcp`, encrypted at rest.
- Tokens are **never** written to `.mcp.json`, the registry (`registry.json`), the links
  file (`links.json`), environment variables, logs, or git.
- `.mcp.json` contains only a non-secret `project_ref` and a `headersHelper` command. At
  connection time Claude Code runs `supa-mcp headers`, which reads the token from the
  keychain in memory and prints only the `Authorization` header.
- `supa-mcp export` deliberately omits tokens; only account names and link metadata are
  exported.

## Reporting a vulnerability

If you believe you have found a security issue, please **do not open a public issue**.
Instead, report it privately via GitHub's
[private vulnerability reporting](https://github.com/im-shubhamsharma/supabase-mcp/security/advisories/new)
("Report a vulnerability" under the repository's **Security** tab).

Please include:
- A description of the issue and its impact.
- Steps to reproduce (with **no real tokens or project refs**).
- Any suggested remediation.

You can expect an initial acknowledgement within a few days. Thank you for helping keep
users safe.

## Rotating a token

If a token is ever exposed, revoke it at
<https://supabase.com/dashboard/account/tokens>, then re-register locally:

```
supa-mcp account add <name>
```
