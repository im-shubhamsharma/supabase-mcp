#!/usr/bin/env bats

load test_helper

setup() { setup_supa; seed_account company; }

@test "link writes a read-only .mcp.json by default" {
  run "$SUPA" link --account company --project-ref refC1 --json
  [ "$status" -eq 0 ]
  [ -f "$WORK/.mcp.json" ]
  run cat "$WORK/.mcp.json"
  [[ "$output" == *"project_ref=refC1"* ]]
  [[ "$output" == *"read_only=true"* ]]
  [[ "$output" == *"supa-mcp headers --account company"* ]]
}

@test "link --write drops read_only" {
  run "$SUPA" link --account company --project-ref refC1 --write --json
  [ "$status" -eq 0 ]
  run cat "$WORK/.mcp.json"
  [[ "$output" != *"read_only=true"* ]]
}

@test "link records the binding in the global links registry" {
  run "$SUPA" link --account company --project-ref refC1 --json
  [ "$status" -eq 0 ]
  run cat "$SUPA_MCP_CONFIG_DIR/links.json"
  [[ "$output" == *"$WORK"* ]]
  [[ "$output" == *"refC1"* ]]
}

@test "link --name adds a second server without clobbering the first" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" link --account company --project-ref refC2 --name staging --json
  [ "$status" -eq 0 ]
  run cat "$WORK/.mcp.json"
  [[ "$output" == *"refC1"* ]]
  [[ "$output" == *"refC2"* ]]
  echo "$output" | jq -e '.mcpServers.supabase and .mcpServers.staging' >/dev/null
}

@test "link rejects an unknown account" {
  run "$SUPA" link --account nope --project-ref refC1
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown account"* ]]
}

@test "link refuses to overwrite invalid JSON" {
  printf 'not json' > "$WORK/.mcp.json"
  run "$SUPA" link --account company --project-ref refC1
  [ "$status" -ne 0 ]
  [[ "$output" == *"not valid JSON"* ]]
}

@test "unlink removes the server and prunes the links registry" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" unlink
  [ "$status" -eq 0 ]
  # The only server was removed, so .mcp.json itself is gone too (see the
  # dedicated "deletes .mcp.json" test below).
  [ ! -f "$WORK/.mcp.json" ]
  run cat "$SUPA_MCP_CONFIG_DIR/links.json"
  [[ "$output" != *"$WORK"* ]]
}

@test "unlink deletes .mcp.json once it has no servers left" {
  "$SUPA" link --account company --project-ref refC1 --json
  run "$SUPA" unlink
  [ "$status" -eq 0 ]
  [ ! -f "$WORK/.mcp.json" ]
}

@test "unlink keeps .mcp.json when another server remains" {
  "$SUPA" link --account company --project-ref refC1 --json
  "$SUPA" link --account company --project-ref refC2 --name staging --json
  run "$SUPA" unlink
  [ "$status" -eq 0 ]
  [ -f "$WORK/.mcp.json" ]
  run cat "$WORK/.mcp.json"
  echo "$output" | jq -e '.mcpServers | has("staging")' >/dev/null
}

@test "link --project resolves a project by name" {
  run "$SUPA" link --account company --project company-staging --json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.project_ref == "refC2"' >/dev/null
  run cat "$WORK/.mcp.json"
  [[ "$output" == *"refC2"* ]]
}

@test "link --project fails clearly for an unknown project name" {
  run "$SUPA" link --account company --project nope
  [ "$status" -ne 0 ]
  [[ "$output" == *"no project named"* ]]
}

@test "link records the project name in the links registry" {
  run "$SUPA" link --account company --project-ref refC1 --json
  [ "$status" -eq 0 ]
  run cat "$SUPA_MCP_CONFIG_DIR/links.json"
  [[ "$output" == *"company-app"* ]]
}
