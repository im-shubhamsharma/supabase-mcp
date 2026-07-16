---
description: Register a Supabase account so supa-mcp can use it (token goes into the macOS Keychain)
allowed-tools: Bash(supa-mcp:*)
---

The user wants to register a Supabase account with supa-mcp. Suggested name: $ARGUMENTS

A Supabase Personal Access Token (PAT) is per account, and one PAT reaches every
organization and project in that account. So the user needs one token per Supabase
login (for example one for "personal" and one for "company").

Do this:

1. Ask the user for a short account name if they did not give one (for example
   `personal` or `company`).
2. Because the token is a secret, do NOT ask the user to paste it into the chat, and do
   not run the add command with the token on the command line. Instead tell the user to
   run this in their own terminal (it prompts for the token with hidden input and stores
   it straight into the Keychain):

   ```
   supa-mcp account add <name>
   ```

   They can create a token at https://supabase.com/dashboard/account/tokens
3. After they confirm they added it, verify without ever seeing the token:

   ```
   supa-mcp account list
   supa-mcp whoami <name>
   ```

   `whoami` prints the organizations and projects that token can see, which confirms it
   is valid and which account it belongs to.

If `supa-mcp` is not found, run `"${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp" install` once to
put it on PATH, then retry.

Reassure the user: the token is stored only in the macOS login Keychain under the
service name `supa-mcp`. It is never written to `.mcp.json`, the registry, environment
variables, or git.
