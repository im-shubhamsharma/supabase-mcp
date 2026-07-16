#!/usr/bin/env bats

load test_helper

setup() { setup_supa; }

@test "account add stores token and registers the account" {
  seed_account personal
  run "$SUPA" account list --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.accounts | index("personal")' >/dev/null
}

@test "account list (plain) shows token presence" {
  seed_account personal
  run "$SUPA" account list
  [ "$status" -eq 0 ]
  [[ "$output" == *"personal"* ]]
  [[ "$output" == *"token present"* ]]
}

@test "account add without a token and no tty fails" {
  run "$SUPA" account add personal
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a terminal"* ]] || [[ "$output" == *"--token"* ]]
}

@test "account remove deletes token and registry entry" {
  seed_account personal
  run "$SUPA" account remove personal
  [ "$status" -eq 0 ]
  run "$SUPA" account list --json
  echo "$output" | jq -e '.accounts | index("personal") | not' >/dev/null
}

@test "empty account list is reported cleanly" {
  run "$SUPA" account list
  [ "$status" -eq 0 ]
  [[ "$output" == *"No accounts registered"* ]]
}

@test "headers hot path prints an Authorization header from the keychain" {
  seed_account company
  run "$SUPA" headers --account company
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.Authorization')" = "Bearer TOKEN_company" ]
}

@test "headers fails for an unknown account" {
  run "$SUPA" headers --account ghost
  [ "$status" -ne 0 ]
}
