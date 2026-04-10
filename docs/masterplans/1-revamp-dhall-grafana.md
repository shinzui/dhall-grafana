# Revamp dhall-grafana for Modern Grafana

Intention: intention_01knvv7t7fe6g9vnshthqzh058

This MasterPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `claude/skills/master-plan/MASTERPLAN.md`.


## Vision & Scope

After this initiative is complete, dhall-grafana will be a maintained, modern Dhall library capable of generating dashboards compatible with Grafana v11. The project will have a reproducible Nix-based development environment using process-compose for service orchestration, replacing the current ad-hoc local-dev setup. The Dhall type system will model the current Grafana dashboard JSON schema (schema version 39+), including modern panel types like TimeSeries, BarChart, PieChart, and Histogram, as well as modernized data source targets.

What is included: a Nix flake with devShell and process-compose for local Grafana + Prometheus with TestData (built-in) as the primary test data source; offline JSON schema validation using grafana-foundation-sdk schemas and dashboard-linter; dashboard provisioning that auto-loads compiled dashboards into Grafana for visual verification; updated core dashboard and field configuration types matching Grafana v11; new panel types that replace legacy panels; modernized data source target types. What is excluded: Grafana Unified Alerting (the alerting model changed so fundamentally that it warrants its own initiative), plugin management, RBAC/permissions modeling, library panels, and Grafana Cloud-specific features.


## Decomposition Strategy

The initiative was decomposed into four work streams organized by functional concern and natural ordering. The first principle was to establish a test environment before making any type changes, since every type modification needs to be validated by compiling example dashboards and loading them into a running Grafana instance. The remaining three plans address the type system in layers: core infrastructure first (dashboard schema, field config), then panel types that build on that core, then data source targets which are orthogonal to panels but depend on the same core types.

An alternative considered was a single monolithic "update all types" plan, but that was rejected because the type changes span too many files and concepts to fit in a manageable ExecPlan. Another alternative was splitting by Grafana concept (one plan per panel type), but that would produce too many trivially small plans with excessive cross-plan coordination overhead. The chosen decomposition of four plans balances scope, independence, and coordination cost.


## Exec-Plan Registry

| # | Title | Path | Hard Deps | Soft Deps | Status |
|---|-------|------|-----------|-----------|--------|
| 1 | Replace local-dev with Nix Flake and Process-Compose | docs/plans/1-nix-flake-process-compose.md | None | None | Not Started |
| 2 | Modernize Core Dashboard Schema and Field Configuration | docs/plans/2-modernize-core-types.md | EP-1 | None | Not Started |
| 3 | Add Modern Panel Types | docs/plans/3-modern-panel-types.md | EP-2 | None | Not Started |
| 4 | Modernize Data Source Targets | docs/plans/4-modernize-datasource-targets.md | EP-2 | EP-3 | Not Started |


## Dependency Graph

EP-1 (Nix Flake and Process-Compose) has no dependencies and must be completed first. It produces the test environment that all subsequent plans depend on to validate their type changes by compiling Dhall to JSON and loading dashboards into a running Grafana instance.

EP-2 (Core Dashboard Schema and Field Configuration) has a hard dependency on EP-1 because it needs the test environment to validate schema changes against a real Grafana v11 instance. EP-2 modernizes the foundational types (Dashboard, FieldConfig, common structures) that all panel types and data source targets build upon.

EP-3 (Modern Panel Types) has a hard dependency on EP-2 because new panel types like TimeSeries use the modernized FieldConfig system extensively, particularly the `defaults.custom` structure that EP-2 introduces. EP-3 cannot define panels without the field configuration foundation.

EP-4 (Data Source Targets) has a hard dependency on EP-2 for the same core type reasons, and a soft dependency on EP-3. The soft dependency exists because example dashboards that validate new targets benefit from having modern panel types available, but EP-4 can proceed with existing panel types if needed.

EP-1 is the sole entry point. After EP-1 completes, only EP-2 can proceed. After EP-2, EP-3 and EP-4 can proceed in parallel.


## Integration Points

The file `package.dhall` at the repository root is the main export point and is touched by EP-2 (updates Dashboard, FieldConfig exports), EP-3 (adds new panel exports), and EP-4 (adds new target exports). EP-2 is responsible for establishing the updated structure. EP-3 and EP-4 must add their exports following the pattern EP-2 establishes.

The file `types/Panels.dhall` defines the Panels union type. EP-2 may adjust the base panel structure, and EP-3 adds new constructors to the union. EP-2 is responsible for the base structure; EP-3 extends it with new variants.

The file `types/FieldConfig.dhall` is modernized by EP-2 and consumed by EP-3 when defining panel-specific field configurations. EP-2 owns the definition; EP-3 uses it.

The file `types/MetricTargets.dhall` defines the union of all metric query types. EP-4 extends this union with new target types following the existing pattern.

The `process-compose.yaml` and `flake.nix` files are created by EP-1 and may be adjusted by later plans if new services or dependencies are needed for testing.


## Progress

- [ ] EP-1: Create flake.nix with devShell containing Grafana, dhall-json, process-compose, just, check-jsonschema, and dashboard-linter
- [ ] EP-1: Create process-compose.yaml for Grafana and Prometheus services
- [ ] EP-1: Create Justfile with service management, build, validate, and watch commands
- [ ] EP-1: Set up .envrc, Grafana provisioning configs, and dashboard auto-loading from out/
- [ ] EP-1: Add JSON schema validation using grafana-foundation-sdk schemas
- [ ] EP-1: Remove old local-dev/ directory
- [ ] EP-1: Validate by starting services, compiling examples, viewing dashboards in Grafana
- [ ] EP-2: Update Dashboard type with new fields and schemaVersion 39
- [ ] EP-2: Modernize FieldConfig with defaults.custom and expanded overrides
- [ ] EP-2: Add modern value mappings, data links, and annotation types
- [ ] EP-2: Update defaults and validate against Grafana v11
- [ ] EP-3: Add TimeSeries panel type (replacement for GraphPanel)
- [ ] EP-3: Add BarChart, PieChart, and Histogram panel types
- [ ] EP-3: Add StateTimeline and StatusHistory panel types
- [ ] EP-3: Update Panels union and package.dhall, validate with example dashboards
- [ ] EP-4: Modernize PrometheusTarget for current query model
- [ ] EP-4: Add Loki target type
- [x] EP-5: InfluxDB support removed (docs/plans/5-remove-influxdb-support.md)
- [ ] EP-4: Update MetricTargets union and validate


## Surprises & Discoveries

(None yet.)


## Decision Log

- Decision: Decompose into four plans: test environment, core types, panel types, data source targets.
  Rationale: This groups work by functional concern with clear dependency ordering. The test environment must come first to validate all subsequent changes. Core types must precede panels and targets since both depend on FieldConfig and Dashboard structures. Panels and targets are relatively independent of each other and can proceed in parallel after core types are done.
  Date: 2026-04-10

- Decision: Target Grafana v11 (schema version 39) rather than the absolute latest nightly.
  Rationale: v11 is the current stable release series with well-documented JSON schema. Targeting a specific stable version ensures the types can be validated against a real Grafana instance available in nixpkgs.
  Date: 2026-04-10

- Decision: Exclude Grafana Unified Alerting from this initiative.
  Rationale: The alerting model changed fundamentally from legacy (per-panel alerts) to Unified Alerting (standalone alert rules, contact points, notification policies). This is a separate domain that warrants its own initiative. The existing legacy Alert type will be kept for backward compatibility but marked as deprecated.
  Date: 2026-04-10

- Decision: Follow the rei-project pattern for Nix flake and process-compose setup.
  Rationale: The user has an established pattern using flake.nix with devShells, process-compose for service orchestration, Justfile for commands, and .envrc for direnv integration. Consistency across projects reduces cognitive overhead and allows reusing known patterns.
  Date: 2026-04-10

- Decision: Drop InfluxDB from the test stack. Use Grafana + TestData + Prometheus instead.
  Rationale: TestData is built into every Grafana installation and supports ~25 data scenarios (random walk, logs, flame graph, annotations, etc.) with zero infrastructure. Prometheus scraping itself provides real metric data for PromQL validation. InfluxDB added complexity for a single example dashboard. The influxdb.dhall example will remain as a compile-only artifact — it validates the InfluxDB Dhall types without needing a running InfluxDB instance.
  Date: 2026-04-10

- Decision: Add offline JSON schema validation and dashboard-linter to the toolchain.
  Rationale: The grafana-foundation-sdk publishes JSON schemas for dashboards and every panel type. Validating compiled JSON against these schemas catches structural errors without running Grafana. The dashboard-linter from Grafana checks best practices (PromQL syntax, templated datasources, panel titles). Together these provide a fast CI-friendly validation tier, while Grafana with dashboard provisioning provides visual verification for local development.
  Date: 2026-04-10


## Outcomes & Retrospective

(To be filled during and after implementation.)
