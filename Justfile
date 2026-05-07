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
      if [ "$(basename "$f")" = "alerting.dhall" ]; then
        continue
      fi
      fileName=$(basename "$f")
      echo "Building $f..."
      dhall-to-json --file "$f" > "out/${fileName/.dhall/.json}"
    done
    echo "Done"

[group("alerting")]
build-alerting:
    mkdir -p grafana/provisioning/alerting
    dhall-to-json --file examples/alerting.dhall > grafana/provisioning/alerting/alerting.json

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

[group("alerting")]
validate-alerting:
    dhall type --file types/Alerting.dhall
    dhall-to-json --file examples/alerting.dhall >/dev/null

[group("alerting")]
reload-alerting:
    curl -sS -X POST http://admin:admin@localhost:3000/api/admin/provisioning/alerting/reload

[group("alerting")]
check-alerting-installed:
    #!/usr/bin/env bash
    set -euo pipefail
    for ep in alert-rules contact-points policies mute-timings templates; do
      code=$(curl -sS -o /dev/null -w '%{http_code}' \
        "http://admin:admin@localhost:3000/api/v1/provisioning/$ep")
      echo "/api/v1/provisioning/$ep -> $code"
      [ "$code" = "200" ]
    done
    echo "Unified Alerting is installed and reachable."

# --- Format ---

[group("format")]
format:
    nix fmt

[group("format")]
check-format:
    nix fmt -- --fail-on-change

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
