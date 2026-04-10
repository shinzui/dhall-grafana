set dotenv-load := false

# --- Services ---

[group("services")]
process-up:
    process-compose up -t=false -L .dev/process-compose.log -U -u .dev/process-compose.sock &

[group("services")]
process-down:
    process-compose down -u .dev/process-compose.sock

# --- Build ---

export TEST_DASHBOARD := "(./package.dhall).ScenarioId.random_walk"

[group("build")]
build:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p out
    for f in examples/*.dhall; do
      fileName=$(basename "$f")
      echo "Building $f..."
      dhall-to-json --file "$f" > "out/${fileName/.dhall/.json}"
    done
    echo "Done"

[group("build")]
build-one file:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p out
    fileName=$(basename "{{file}}")
    echo "Building {{file}}..."
    dhall-to-json --file "{{file}}" > "out/${fileName/.dhall/.json}"

# --- Validate ---

[group("validate")]
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in out/*.json; do
      echo "Validating $f..."
      check-jsonschema --schemafile schemas/grafana/dashboard.jsonschema.json "$f"
    done

[group("validate")]
check-all: build validate

# --- Format ---

[group("format")]
format:
    treefmt

[group("format")]
check-format:
    treefmt --fail-on-change

# --- Dev ---

[group("dev")]
watch file:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Watching {{file}} for changes (Ctrl-C to stop)..."
    echo "Dashboards auto-reload in Grafana via provisioning."
    # Build once immediately
    just build-one "{{file}}"
    # Then watch for changes
    fswatch -o "{{file}}" | while read -r _; do
      echo "Change detected, rebuilding {{file}}..."
      just build-one "{{file}}"
    done

# --- Nix ---

[group("nix")]
nix-check:
    nix flake check
