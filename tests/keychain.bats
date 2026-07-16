#!/usr/bin/env bats
# Exercises the cross-platform keychain abstraction. The default backend is the
# macOS `security` stub; here we force the Linux `secret-tool` backend to prove
# the same behavior on that code path.

load test_helper

@test "secret-tool (Linux) backend stores and reads a token" {
  export SUPA_MCP_KEYCHAIN=secret-tool
  setup_supa
  seed_account company
  run "$SUPA" headers --account company
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.Authorization')" = "Bearer TOKEN_company" ]
}

@test "secret-tool backend removes a token on account remove" {
  export SUPA_MCP_KEYCHAIN=secret-tool
  setup_supa
  seed_account company
  "$SUPA" account remove company
  run "$SUPA" headers --account company
  [ "$status" -ne 0 ]
}

@test "an unsupported keychain backend fails with a clear message" {
  export SUPA_MCP_KEYCHAIN=nonsense
  setup_supa
  run "$SUPA" account add x --token y
  [ "$status" -ne 0 ]
  [[ "$output" == *"keychain"* ]] || [[ "$output" == *"backend"* ]]
}
