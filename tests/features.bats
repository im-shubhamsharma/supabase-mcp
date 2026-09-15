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
  seed_account broken BADTOKEN --force
  run "$SUPA" doctor
  [[ "$output" == *"broken"* ]]
  [[ "$output" == *"invalid"* ]] || [[ "$output" == *"INVALID"* ]]
}

@test "account add rejects an invalid token without --force" {
  run "$SUPA" account add broken --token BADTOKEN
  [ "$status" -ne 0 ]
  [[ "$output" == *"rejected"* ]] || [[ "$output" == *"Not stored"* ]]
  run "$SUPA" account list --json
  echo "$output" | jq -e '.accounts | index("broken") | not' >/dev/null
}

@test "account add rejects an invalid account name" {
  run "$SUPA" account add "bad name" --token TOKEN_x
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid account name"* ]]
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

@test "statusline includes the project name once known" {
  "$SUPA" link --account company --project company-app --json
  run "$SUPA" statusline
  [ "$status" -eq 0 ]
  [[ "$output" == *"company-app"* ]]
}

# ---- name-based switch/branch resolution (new) ----

@test "switch --project resolves a project by name on the same account" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" switch --project company-staging --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.project_ref == "refC2"' >/dev/null
}

@test "switch --branch resolves a branch by name on the current project" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" switch --branch preview --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.project_ref == "brC1"' >/dev/null
}

@test "switch --project fails clearly for an unknown project name" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" switch --project nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"no project named"* ]]
}

# ---- open (new) ----

@test "open hands the dashboard URL to the (stubbed) opener" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" open
  [ "$status" -eq 0 ]
  [[ "$output" == *"https://supabase.com/dashboard/project/refC1"* ]]
}

@test "open fails when the directory is not linked" {
  run "$SUPA" open
  [ "$status" -ne 0 ]
}

# ---- project-list caching (new) ----

@test "list --verify reuses one cached project list across directories on the same account" {
  mkdir -p "$WORK/a" "$WORK/b"
  ( cd "$WORK/a" && "$SUPA" link --account company --project-ref refC1 --json )
  ( cd "$WORK/b" && "$SUPA" link --account company --project-ref refC2 --json )
  run "$SUPA" list --json --verify
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '[.links[].verified] == ["true","true"]' >/dev/null
  [ -f "$SUPA_MCP_CONFIG_DIR/cache/company.json" ]
}

@test "projects --refresh bypasses a warm cache" {
  "$SUPA" projects company --json >/dev/null
  [ -f "$SUPA_MCP_CONFIG_DIR/cache/company.json" ]
  run "$SUPA" projects company --json --refresh
  [ "$status" -eq 0 ]
  echo "$output" | jq -e 'map(.ref) | index("refC1")' >/dev/null
}

# ---- init (new) ----

@test "init fails cleanly with no accounts and no terminal" {
  run "$SUPA" account remove company
  run "$SUPA" init
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a terminal"* ]] || [[ "$output" == *"account add"* ]]
}
