# Shared setup for supa-mcp bats tests.
#
# Isolates every test from the real Keychain, network, and user config by:
#   - pointing SUPA_MCP_CONFIG_DIR at a per-test temp dir
#   - prepending tests/stubs to PATH so `security`, `secret-tool`, and `curl`
#     are the fakes, not the real tools
#   - backing the fake keychain onto a per-test temp store

setup_supa() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SUPA="$REPO_ROOT/bin/supa-mcp"

  export SUPA_MCP_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  export SUPA_MCP_TEST_KC="$BATS_TEST_TMPDIR/kc"
  mkdir -p "$SUPA_MCP_CONFIG_DIR" "$SUPA_MCP_TEST_KC"

  # Default keychain backend for tests is the macOS `security` stub; individual
  # tests can override with SUPA_MCP_KEYCHAIN=secret-tool.
  export SUPA_MCP_KEYCHAIN="${SUPA_MCP_KEYCHAIN:-security}"

  PATH="$REPO_ROOT/tests/stubs:$PATH"

  WORK="$BATS_TEST_TMPDIR/work"
  mkdir -p "$WORK"
  cd "$WORK" || return 1
}

# Register an account directly with a known fixture token (bypasses the hidden
# prompt). Fixture tokens are TOKEN_<account>; use BADTOKEN for an invalid one
# (pass "--force" as a 3rd arg to store it despite failed validation).
seed_account() {
  local name="$1" token="${2:-TOKEN_$1}" extra="${3:-}"
  if [ -n "$extra" ]; then
    run "$SUPA" account add "$name" --token "$token" $extra
  else
    run "$SUPA" account add "$name" --token "$token"
  fi
  [ "$status" -eq 0 ] || {
    echo "seed_account failed: $output" >&2
    return 1
  }
}
