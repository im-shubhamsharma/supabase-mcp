#!/usr/bin/env bats

load test_helper

setup() { setup_supa; seed_account company; }

# ---- whoami / projects ----

@test "whoami lists orgs and projects for an account" {
  run "$SUPA" whoami company --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.projects | length == 2' >/dev/null
  echo "$output" | jq -e '[.projects[].name] | index("company-app")' >/dev/null
}

@test "projects lists an account's projects" {
  run "$SUPA" projects company --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e 'map(.ref) | index("refC2")' >/dev/null
}

# ---- branches (new) ----

@test "branches lists a project's branches" {
  run "$SUPA" branches company refC1 --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '[.[].name] | index("preview")' >/dev/null
  echo "$output" | jq -e '[.[] | select(.is_default) | .name] | index("main")' >/dev/null
}

@test "branches plain output is human readable" {
  run "$SUPA" branches company refC1
  [ "$status" -eq 0 ]
  [[ "$output" == *"preview"* ]]
}

# ---- list (new: global overview) ----

@test "list shows every linked directory across the machine" {
  mkdir -p "$WORK/a" "$WORK/b"
  ( cd "$WORK/a" && "$SUPA" link --account company --project-ref refC1 --json )
  ( cd "$WORK/b" && "$SUPA" link --account company --project-ref refC2 --json )
  run "$SUPA" list --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.links | length == 2' >/dev/null
  echo "$output" | jq -e '[.links[].project_ref] | index("refC1") and index("refC2")' >/dev/null
}

@test "list prunes directories whose .mcp.json is gone" {
  mkdir -p "$WORK/gone"
  ( cd "$WORK/gone" && "$SUPA" link --account company --project-ref refC1 --json )
  rm -rf "$WORK/gone"
  run "$SUPA" list --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.links | length == 0' >/dev/null
}

# ---- switch (new) ----

@test "switch re-points the current directory to a new project" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" switch --project-ref refC2 --json
  [ "$status" -eq 0 ]
  run cat "$WORK/.mcp.json"
  [[ "$output" == *"refC2"* ]]
  [[ "$output" != *"refC1"* ]]
}

@test "switch keeps the existing account when only a ref is given" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" switch --project-ref refC2 --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.account == "company"' >/dev/null
}

@test "switch fails when the directory is not linked" {
  run "$SUPA" switch --project-ref refC2
  [ "$status" -ne 0 ]
}

# ---- doctor token health (new) ----

@test "doctor reports a valid token as ok" {
  run "$SUPA" doctor
  [[ "$output" == *"company"* ]]
  [[ "$output" == *"valid"* ]] || [[ "$output" == *"ok"* ]]
}

@test "doctor flags an invalid token" {
  seed_account broken BADTOKEN
  run "$SUPA" doctor
  [[ "$output" == *"broken"* ]]
  [[ "$output" == *"invalid"* ]] || [[ "$output" == *"INVALID"* ]]
}

# ---- export / import (new) ----

@test "export emits accounts and links without secrets" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" export
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.accounts | index("company")' >/dev/null
  [[ "$output" != *"TOKEN_company"* ]]
}

@test "import merges accounts from a bundle" {
  bundle='{"accounts":["imported"],"links":[]}'
  run bash -c "printf '%s' '$bundle' | '$SUPA' import"
  [ "$status" -eq 0 ]
  run "$SUPA" account list --json
  echo "$output" | jq -e '.accounts | index("imported")' >/dev/null
}

# ---- version / statusline (new) ----

@test "version prints a semver" {
  run "$SUPA" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "statusline is empty when not linked" {
  run "$SUPA" statusline
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "statusline shows account/project/mode when linked" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" statusline
  [ "$status" -eq 0 ]
  [[ "$output" == *"company"* ]]
  [[ "$output" == *"refC1"* ]]
}
