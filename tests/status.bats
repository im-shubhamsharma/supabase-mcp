#!/usr/bin/env bats

load test_helper

setup() { setup_supa; seed_account company; }

@test "status reports not linked in a fresh dir" {
  run "$SUPA" status --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.linked == false' >/dev/null
}

@test "status verifies a correctly linked directory" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" status --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.linked == true' >/dev/null
  echo "$output" | jq -e '.account == "company"' >/dev/null
  echo "$output" | jq -e '.project_ref == "refC1"' >/dev/null
  echo "$output" | jq -e '.account_verified == "true"' >/dev/null
  echo "$output" | jq -e '.project_name == "company-app"' >/dev/null
}

@test "status flags a wrong-account binding" {
  # Pin a ref that belongs to 'personal', but claim it is 'company'
  seed_account personal
  "$SUPA" link --account company --project-ref refP1 --json
  run "$SUPA" status --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.account_verified == "false"' >/dev/null
}

@test "status --no-verify skips the live check" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" status --json --no-verify
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.account_verified == "skipped"' >/dev/null
}
