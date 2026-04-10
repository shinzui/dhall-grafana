# Replace local-dev with Nix Flake and Process-Compose

Intention: intention_01knvv7t7fe6g9vnshthqzh058

MasterPlan: docs/masterplans/1-revamp-dhall-grafana.md

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `.claude/skills/exec-plan/PLANS.md`.


## Purpose / Big Picture

After this change, a developer can enter the dhall-grafana directory, run `direnv allow` (or `nix develop`), and immediately have all tools available: dhall-json for compiling Dhall to JSON, a running Grafana v11 instance with provisioned TestData and Prometheus data sources, dashboard-linter for best-practice checks, and JSON schema validation for offline structural verification. Compiled example dashboards are auto-loaded into Grafana via the provisioning system, so you can view them immediately at `http://localhost:3000`.

Starting and stopping services is done via `just process-up` and `just process-down`, following the same process-compose pattern used in the rei-project. The old `local-dev/` directory with its shell.nix, Procfile, and foreman-based workflow is removed entirely.

To see it working: enter the dev shell, run `just process-up`, then run `just build` to compile all example dashboards to `out/`. Open `http://localhost:3000` in a browser — the compiled dashboards appear automatically in Grafana because the provisioning system watches the `out/` directory. Run `just validate` to check the JSON against Grafana's published schemas without needing a running instance.


## Progress

- [x] Create flake.nix with inputs (nixpkgs, flake-utils, treefmt-nix, pre-commit-hooks) and devShell (2026-04-10)
- [x] Create process-compose.yaml with Grafana and Prometheus processes (2026-04-10)
- [x] Create Justfile with service management, build, validate, format, and watch commands (2026-04-10)
- [x] Create .envrc for direnv integration (2026-04-10)
- [x] Create treefmt.nix for Dhall formatting configuration (2026-04-10)
- [x] Migrate and update Grafana provisioning configs to grafana/ at repo root (2026-04-10)
- [x] Configure dashboard provisioning to auto-load compiled JSON from out/ (2026-04-10)
- [x] Set up JSON schema validation using grafana-foundation-sdk schemas (2026-04-10)
- [ ] Add dashboard-linter to the toolchain (skipped — not in nixpkgs, defer to follow-up)
- [x] Update .gitignore for new paths (.dev/, .direnv/, out/, result) (2026-04-10)
- [x] Remove local-dev/ directory and build_examples.sh (2026-04-10)
- [x] Update README.md with new development workflow (2026-04-10)
- [x] Update .github/workflows/main.yml to use Nix flake for CI (2026-04-10)
- [ ] Validate: enter dev shell, start services, build examples, view dashboards in Grafana, run schema validation


## Surprises & Discoveries

- `grafana-server` CLI is deprecated in Grafana 12.x. The new command is `grafana server`. Updated process-compose.yaml accordingly.
- `dashboard-linter` is not packaged in nixpkgs. Will need `buildGoModule` or skip for now. Skipping in Milestone 1; will revisit in Milestone 2.
- treefmt-nix has built-in `programs.dhall.enable` support, so dhall formatting works through treefmt without custom hooks.
- Schema validation (`check-jsonschema`) correctly fails on all current examples. The Dhall types generate legacy Grafana JSON (singlestat/graph panels, string datasource refs, missing `annotations` field). This confirms the grafana-foundation-sdk schema is working and shows exactly what EP-2/3/4 need to modernize. The `just validate` command is wired up and ready — it will pass once the types are updated.


## Decision Log

- Decision: Place Grafana provisioning configs at `grafana/` in the repo root rather than nested under a dev directory.
  Rationale: The provisioning configs (datasources, dashboards) are integral to the project's test infrastructure, not an afterthought. Placing them at the root makes them discoverable and signals that they are first-class project files. This follows the pattern of having process-compose.yaml and Justfile at the root.
  Date: 2026-04-10

- Decision: Use treefmt-nix with dhall formatting rather than the current CI-based dhall format check.
  Rationale: treefmt integrates with the Nix flake checks and pre-commit hooks, providing consistent formatting locally and in CI. This replaces the current approach of downloading dhall binaries in GitHub Actions.
  Date: 2026-04-10

- Decision: Drop InfluxDB from the test environment. Use Grafana + TestData + Prometheus.
  Rationale: TestData is built into Grafana and supports ~25 data scenarios with zero infrastructure. Prometheus scraping itself provides real metric data for PromQL validation. InfluxDB added a heavy service for a single example dashboard. The influxdb.dhall example remains as a compile-only artifact validating the InfluxDB Dhall types. The provisioning only needs testdata.yaml and prometheus.yaml.
  Date: 2026-04-10

- Decision: Auto-load compiled dashboards into Grafana via provisioning rather than requiring manual API calls.
  Rationale: Grafana's file-based dashboard provisioning watches a directory and auto-loads/reloads JSON files. By pointing the provisioner at `out/` (where `just build` writes compiled JSON), dashboards appear in Grafana automatically after building. This removes the need for curl-based API upload and makes the workflow: build then refresh browser.
  Date: 2026-04-10

- Decision: Add two-tier validation: offline JSON schema checks (fast, CI) and visual Grafana verification (local dev).
  Rationale: The grafana-foundation-sdk publishes JSON schemas for dashboard structure and every panel type. Validating against these catches structural errors without Grafana. dashboard-linter checks best practices (PromQL syntax, templated datasources). Together these provide a fast CI validation tier complementing visual Grafana verification.
  Date: 2026-04-10

- Decision: Skip dashboard-linter for now; defer to a follow-up task.
  Rationale: dashboard-linter is not packaged in nixpkgs. Building from source with `buildGoModule` adds complexity to the flake. The JSON schema validation via check-jsonschema already provides structural validation. dashboard-linter can be added later when the types are modernized and there are valid dashboards to lint.
  Date: 2026-04-10


## Outcomes & Retrospective

(To be filled during and after implementation.)


## Context and Orientation

The dhall-grafana project is a Dhall library for generating Grafana dashboard JSON. It lives at the repository root with this structure:

    package.dhall          — main entry point exporting all types and defaults
    types/                 — 32 Dhall files defining Grafana types
    defaults/              — 20 Dhall files with default values
    examples/              — 4 example dashboard Dhall files
    schemas/               — 2 Dhall files for Lucene support
    build_examples.sh      — nix-shell script that compiles examples to JSON
    local-dev/             — current dev environment (to be replaced)
    .github/workflows/     — CI configuration

The current development environment lives in `local-dev/` and consists of:

`local-dev/shell.nix` — a Nix shell that provides Grafana, InfluxDB, Prometheus, dhall-json, fswatch, jq, curl, and foreman. It defines custom wrapper scripts (`run-grafana-server`, `run-influx-server`, `run-prometheus-server`) inline using `writeShellScriptBin`. Data is stored in `local-dev/data/`.

`local-dev/Procfile` — a foreman process file that starts grafana, influxdb, and prometheus using the wrapper scripts from shell.nix.

`local-dev/watch.sh` — a file watcher that compiles a Dhall file to JSON on change and pushes it to Grafana's API via curl. It only supports Linux (uses xdotool for browser reload).

`local-dev/grafana/grafana.ini` — Grafana configuration enabling anonymous admin access, pointing to `$DATA_PATH` and `$CONFIG_PATH` for runtime directories.

`local-dev/grafana/provisioning/datasources/` — three YAML files provisioning TestData DB (default), Prometheus (localhost:9090), and InfluxDB (localhost:8086 with NOAA_water_database).

The target pattern comes from the rei-project at `/Users/shinzui/Keikaku/bokuno/rei-project/rei`, which uses:

`flake.nix` — a Nix flake with `flake-utils.lib.eachDefaultSystem` producing `devShells.default`, `formatter`, and `checks`. The devShell provides all tools via `nativeBuildInputs` and uses `shellHook` for environment setup (creating directories, initializing state). Pre-commit hooks are wired via `pre-commit-hooks.nix`.

`process-compose.yaml` — version 0.5, with processes that have readiness probes, dependency ordering via `depends_on` with `condition: process_healthy`, and a log file at `.dev/process-compose.log`.

`Justfile` — grouped commands using `[group("...")]` annotations. Service commands are `just process-up` (starts process-compose without TUI, with unix socket at `.dev/process-compose.sock`) and `just process-down`.

`.envrc` — two lines: `use flake` and `eval "$shellHook"`, followed by project-specific environment variables.

`treefmt.nix` — formatting configuration consumed by the flake's `formatter` and `checks.formatting` outputs.

The grafana-foundation-sdk at `https://github.com/grafana/grafana-foundation-sdk` publishes JSON schema files in its `/jsonschema/` directory, including `dashboard.jsonschema.json` for validating complete dashboard JSON. These schemas are generated by Grafana's Cog code generator from the canonical CUE schemas in the Grafana source.

The `dashboard-linter` at `https://github.com/grafana/dashboard-linter` is a Go CLI that checks Grafana dashboard JSON for best practices: PromQL/LogQL syntax validation, templated datasource usage, panel title/description presence, rate interval patterns, and counter aggregation rules.


## Plan of Work

This plan has three milestones. The first creates the Nix flake and process-compose infrastructure with the modern validation stack. The second sets up Grafana provisioning with dashboard auto-loading and creates the Justfile. The third removes the old local-dev directory and validates the complete setup end-to-end.


### Milestone 1: Nix Flake and Process-Compose Foundation

After this milestone, `nix develop` enters a shell with dhall-json, process-compose, just, check-jsonschema, dashboard-linter, jq, and curl available. Running `process-compose up` starts Grafana and Prometheus with health checks.

Create `flake.nix` at the repository root. The flake should have these inputs:

    nixpkgs — github:nixos/nixpkgs/nixpkgs-unstable
    flake-utils — github:numtide/flake-utils
    treefmt-nix — github:numtide/treefmt-nix
    pre-commit-hooks — github:cachix/pre-commit-hooks.nix

The outputs section uses `flake-utils.lib.eachDefaultSystem` to produce per-system outputs. The `devShells.default` must include in `nativeBuildInputs`: `pkgs.dhall-json` (provides both `dhall` and `dhall-to-json`), `pkgs.process-compose`, `pkgs.just`, `pkgs.jq`, `pkgs.curl`, `pkgs.fswatch`, `pkgs.grafana`, `pkgs.prometheus`, and `pkgs.check-jsonschema` (a Python-based JSON schema validator available in nixpkgs). For `dashboard-linter`, check if it is packaged in nixpkgs; if not, it can be fetched as a Go binary or built from source using `pkgs.buildGoModule`. An alternative is to use `pkgs.python3Packages.jsonschema` or `pkgs.ajv-cli` for schema validation — pick whichever is available and simplest in nixpkgs.

The `shellHook` should create a `.dev` directory and an `out` directory for compiled dashboard JSON, and wire up pre-commit hooks. Following the rei-project pattern:

    ${self.checks.${system}.pre-commit-check.shellHook}
    mkdir -p .dev
    mkdir -p out

The flake should also produce `formatter` (treefmt wrapper), `checks.formatting` (treefmt check), and `checks.pre-commit-check` (treefmt + dhall format hooks).

Create `treefmt.nix` at the repository root. It should enable `nixpkgs-fmt` for nix files. Dhall formatting can be configured either via treefmt's dhall formatter or via a custom pre-commit hook that runs `dhall format`.

Create `process-compose.yaml` at the repository root with version 0.5. Define two processes:

The `grafana` process runs the Grafana server binary pointing to the provisioning config at `./grafana` and storing data in `.dev/grafana`. It needs a readiness probe — an HTTP check against `http://localhost:3000/api/health` or a simpler process status check. Set `availability.restart: on_failure`. The process should set environment variables `DATA_PATH` and `CONFIG_PATH` used by `grafana.ini`.

The `prometheus` process starts Prometheus with `--config.file=./prometheus.yml` and `--storage.tsdb.path=.dev/prometheus`. Add a readiness probe (HTTP check on port 9090 or process status) and `availability.restart: on_failure`.

Create `.envrc` at the repository root with:

    use flake
    eval "$shellHook"

Create `prometheus.yml` at the repository root with a basic scrape configuration — Prometheus scraping itself at localhost:9090. This provides real metric data for PromQL validation without any additional services:

    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["localhost:9090"]

Acceptance for this milestone: run `nix develop`, then `process-compose up`. Grafana should be accessible at `http://localhost:3000`. Prometheus at `http://localhost:9090`. Both processes should show healthy in process-compose output.


### Milestone 2: Grafana Provisioning, Justfile, and Validation Tooling

After this milestone, `just process-up` starts all services, `just build` compiles all example dashboards to `out/`, dashboards appear automatically in Grafana, `just validate` checks JSON against Grafana schemas, and `just watch <file>` live-reloads a single dashboard.

Move the Grafana provisioning configuration from `local-dev/grafana/` to `grafana/` at the repository root. The new structure:

    grafana/
      grafana.ini
      provisioning/
        datasources/
          testdata.yaml        — TestData DB (default, built into Grafana)
          prometheus.yaml      — Prometheus at localhost:9090
        dashboards/
          default.yaml         — dashboard provisioner config pointing at out/

Remove `influxdb.yaml` from the datasources — InfluxDB is no longer in the stack. Keep `testdata.yaml` and `prometheus.yaml`. Update `grafana.ini` to use paths relative to the new layout with `DATA_PATH` pointing to `.dev/grafana` and `CONFIG_PATH` pointing to `./grafana`.

Create `grafana/provisioning/dashboards/default.yaml` to configure Grafana's dashboard provisioning. This tells Grafana to watch the `out/` directory for JSON files and auto-load them:

    apiVersion: 1
    providers:
      - name: 'dhall-grafana-examples'
        orgId: 1
        folder: 'Examples'
        type: file
        updateIntervalSeconds: 5
        options:
          path: /path/to/out
          foldersFromFilesStructure: false

The `path` must be absolute. The process-compose grafana process should set an environment variable (e.g., `DASHBOARDS_PATH`) that resolves to `$PWD/out`, and `default.yaml` can use Grafana's environment variable interpolation (`$__env{DASHBOARDS_PATH}`) or the grafana process command can template the path. Alternatively, the shellHook can generate this file with the correct absolute path. Determine the cleanest approach during implementation.

Create `Justfile` at the repository root with these command groups:

Services group: `process-up` starts process-compose without TUI using a unix socket at `.dev/process-compose.sock`. `process-down` stops process-compose.

Build group: `build` runs dhall-to-json on all example files, outputting JSON to `out/`. This replaces `build_examples.sh`. `build-one file` compiles a single Dhall file to JSON and writes it to `out/`.

Validate group: `validate` runs JSON schema validation on all files in `out/` against the Grafana dashboard schema. `lint` runs dashboard-linter on all files in `out/`. `check-all` runs both validate and lint.

Format group: `format` runs dhall format on all .dhall files (or delegates to treefmt). `check-format` runs dhall format --check.

Dev group: `watch file` watches a Dhall file for changes using fswatch, compiles it to JSON in `out/` on each change. Because Grafana's provisioner watches `out/`, the dashboard auto-reloads in the browser — no curl API calls needed, just refresh the page. This is cross-platform (works on macOS and Linux) unlike the old watch.sh which only worked on Linux.

Download the Grafana dashboard JSON schema. This can be done as part of the flake build (fetching from grafana-foundation-sdk), as a checked-in file in `schemas/grafana/`, or downloaded on first use by a just command. The simplest approach is to check in the schema file at `schemas/grafana/dashboard.jsonschema.json` fetched from the grafana-foundation-sdk repository, and update it periodically. This avoids network dependencies at validation time.

Update `.gitignore` at the repository root to include: `.dev/`, `.direnv/`, `out/`, `result`, and `result-*` (nix build outputs).

Acceptance for this milestone: run `just process-up`, then `just build`. The `out/` directory contains JSON files for all examples. Open `http://localhost:3000` — the compiled dashboards appear in the "Examples" folder automatically. Run `just validate` and verify all dashboards pass schema validation. Run `just watch examples/all_dashboard.dhall`, change the title in the Dhall file, run `just build`, and see the change in Grafana after refreshing the page.


### Milestone 3: Remove local-dev and Validate Complete Setup

After this milestone, the `local-dev/` directory is gone, the old `build_examples.sh` is removed, and the project uses the new Nix flake exclusively.

Remove the `local-dev/` directory entirely: `local-dev/shell.nix`, `local-dev/Procfile`, `local-dev/watch.sh`, `local-dev/reload-linux.sh`, `local-dev/grafana/` (now migrated to repo root), `local-dev/.gitignore`, and `local-dev/README.md`.

Remove `build_examples.sh` from the repository root since `just build` replaces it.

Update the `influxdb.dhall` example to be a compile-only example. It already uses InfluxDB-specific types which are still valid Dhall types — the example will continue to compile with `just build` and produce valid JSON. It just won't have a running InfluxDB to query against. Add a comment at the top of the example noting this, or rename it to indicate it demonstrates InfluxDB types without a live data source.

Update `README.md` to reflect the new development workflow: entering the dev shell via `direnv allow` or `nix develop`, starting services with `just process-up`, building examples with `just build`, viewing dashboards at `http://localhost:3000` in the "Examples" folder, running `just validate` for schema validation, and watching files with `just watch`.

Update `.github/workflows/main.yml` to use the Nix flake for CI. The lint job can use `nix flake check` which runs treefmt (including dhall format). The build job can use `nix develop --command just build` followed by `nix develop --command just validate` for schema validation. This replaces the current approach of downloading dhall binaries manually in CI.

Acceptance for this milestone: from a clean checkout, run `nix develop`, then `just process-up`, then `just build`. All example dashboards compile successfully. Open `http://localhost:3000` and verify dashboards appear in the "Examples" folder with all panels rendering. TestData and Prometheus data sources should be visible under Configuration > Data Sources. Run `just validate` and confirm all dashboards pass. Run `just process-down` to stop all services cleanly.


## Concrete Steps

Working directory for all commands is the repository root: `/Users/shinzui/Keikaku/bokuno/dhall-grafana`.

Enter the dev shell after creating flake.nix:

    nix develop

Verify tools are available:

    dhall-to-json --version
    process-compose version
    just --version
    check-jsonschema --version

Start services:

    just process-up

Expected output should show grafana and prometheus processes starting with health check status.

Build all examples:

    just build

Expected output:

    Building examples/all_dashboard.dhall...
    Building examples/consul_exporter.dhall...
    Building examples/hass_indoor.dhall...
    Building examples/influxdb.dhall...
    Done

Verify dashboards are visible in Grafana — open `http://localhost:3000`, navigate to Dashboards, and find the "Examples" folder. All four dashboards should be listed and viewable.

Validate against Grafana schemas:

    just validate

Expected output:

    Validating out/all_dashboard.json... ok
    Validating out/consul_exporter.json... ok
    Validating out/hass_indoor.json... ok
    Validating out/influxdb.json... ok

Run dashboard linter:

    just lint

Verify Grafana is healthy:

    curl -s http://localhost:3000/api/health | jq .

Expected output:

    {
      "commit": "...",
      "database": "ok",
      "version": "..."
    }

Stop services:

    just process-down


## Validation and Acceptance

The complete validation sequence is: enter the dev shell, start services with `just process-up`, wait for both processes to report healthy, run `just build` to compile all example dashboards, open `http://localhost:3000` and navigate to the "Examples" folder to verify all dashboards are loaded and viewable with panels rendering, run `just validate` to confirm all JSON passes schema validation, run `just lint` for best-practice checks. Then run `just process-down` and verify both processes stop cleanly.

Additionally, verify formatting works: run `just format` (or `nix fmt`) and confirm no Dhall files are modified (the codebase is already formatted). Run `nix flake check` and confirm all checks pass.

The key visual verification: after `just build`, refresh Grafana in the browser and confirm that the all_dashboard.dhall example renders with its text panels, graph panels, stat panels, and all templating variables visible in the dashboard header.


## Idempotence and Recovery

All commands are safe to repeat. `just process-up` will fail if services are already running; run `just process-down` first. The `.dev/` directory can be deleted entirely to reset all runtime state (Grafana data, Prometheus TSDB). The `out/` directory can be deleted and regenerated with `just build`. The `nix develop` command is always safe to run and will recreate the shell environment from the flake lock.


## Interfaces and Dependencies

This plan depends on the following nixpkgs packages: `grafana` (Grafana server binary), `prometheus` (Prometheus binary), `dhall-json` (provides `dhall` and `dhall-to-json` commands), `process-compose` (service orchestrator), `just` (command runner), `jq` (JSON processor), `curl` (HTTP client), `fswatch` (file watcher for the watch command), and `check-jsonschema` or equivalent JSON schema validator.

For `dashboard-linter`: check nixpkgs for availability. If not packaged, either build from source with `buildGoModule` or skip in the initial setup and add it as a follow-up enhancement.

The flake.nix must produce these outputs:

    devShells.${system}.default — mkShell with all tools
    formatter.${system} — treefmt wrapper
    checks.${system}.formatting — treefmt validation
    checks.${system}.pre-commit-check — pre-commit hook runner

The process-compose.yaml must define these processes:

    grafana — Grafana server with provisioning from ./grafana, dashboard auto-load from out/
    prometheus — Prometheus with config from ./prometheus.yml

The Justfile must provide these commands:

    just process-up — start services via process-compose
    just process-down — stop services
    just build — compile all example dashboards to out/
    just build-one <file> — compile a single Dhall file to out/
    just validate — check all JSON in out/ against Grafana dashboard schema
    just lint — run dashboard-linter on all JSON in out/
    just watch <file> — watch and auto-compile a dashboard (Grafana provisioner picks up changes)
    just format — format all Dhall files
