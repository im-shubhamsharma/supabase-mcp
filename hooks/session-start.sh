#!/usr/bin/env bash
#
# supa-mcp SessionStart hook (proactive wrong-account guard).
#
# Runs when a Claude Code session starts or resumes. It is deliberately
# LOCAL-ONLY and fast: SessionStart hooks block session startup, and this hook
# runs in every project once the plugin is installed, so it must not make a
# network call. It reads the current directory's binding from .mcp.json and, if
# this directory is linked to a Supabase project, surfaces which account and
# project are pinned and nudges the user to run /supa-status for the live
# wrong-account check. In an unlinked directory it prints nothing and exits 0.

set -uo pipefail

# Prefer a supa-mcp on PATH; fall back to the copy bundled in the plugin.
cli="$(command -v supa-mcp 2>/dev/null || true)"
if [ -z "$cli" ] && [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  cli="${CLAUDE_PLUGIN_ROOT}/bin/supa-mcp"
fi
[ -n "$cli" ] && [ -x "$cli" ] || exit 0

# Fast, local, no-network summary: "supabase: <account>/<ref> (ro|rw)" or empty.
line="$("$cli" statusline 2>/dev/null || true)"
[ -n "$line" ] || exit 0

printf 'supa-mcp: this directory is linked to Supabase — %s.\n' "$line"
printf 'Run /supa-status to confirm the pinned project belongs to the linked account before running SQL.\n'
exit 0
