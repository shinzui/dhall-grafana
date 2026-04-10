# Modernize Data Source Targets

Intention: intention_01knvv7t7fe6g9vnshthqzh058

MasterPlan: docs/masterplans/1-revamp-dhall-grafana.md

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `.claude/skills/exec-plan/PLANS.md`.


## Purpose / Big Picture

After this change, the data source target types in dhall-grafana reflect the modern Grafana v11 query model. The PrometheusTarget is updated with fields for the modern query editor (range/instant toggle, format options, editor mode). A new LokiTarget type is added for Grafana Loki, the log aggregation system commonly paired with Prometheus. The InfluxDB target gains Flux query support alongside the existing InfluxQL model, since Grafana now supports both query languages for InfluxDB. The MetricTargets union is extended with the new target types.

To see it working: write a Dhall dashboard with a Loki target querying `{job="grafana"}`, compile it with `just build`, and load it into Grafana. The panel should show the Loki data source with the query correctly configured.


## Progress

- [x] Modernize PrometheusTarget with current query editor fields (2026-04-10)
- [x] Add datasource field (type + uid) to all target types for modern Grafana data source references (2026-04-10)
- [x] Add LokiTarget type, default, and smart constructor (2026-04-10)
- [x] Add Flux query support to InfluxDB target (compile-only validation, no running InfluxDB) (2026-04-10)
- [x] Update MetricTargets union with new target types (2026-04-10)
- [x] Update package.dhall with new exports (2026-04-10)
- [x] Update example dashboards for compatibility with new target types (2026-04-10)
- [x] Validate targets compile correctly — all examples build, LokiTarget standalone expression verified (2026-04-10)
- [x] Live validation against Grafana v12.4.2 — all dashboards provisioned, Prometheus and TestData queries execute, panels render (2026-04-10)


## Surprises & Discoveries

- Examples using direct record literals (influxdb.dhall, all_dashboard.dhall, modern_panels.dhall) needed conversion to `::` record completion syntax, since adding new fields to a type breaks direct literal construction. The plan assumed all new Optional fields would be transparent, but this only holds for code using `::` completion. Converted these examples to use `::` syntax which is both more concise and forward-compatible.

- The `legendFormat` change from `Optional Text` to `Text` required updating consul_exporter.dhall to remove `Some` wrappers (3 occurrences). This was expected but worth noting as a breaking change for any external Dhall code using `Some` with legendFormat.


## Decision Log

- Decision: Add LokiTarget as the only new data source type in this plan.
  Rationale: Loki is the most commonly used data source alongside Prometheus in the Grafana ecosystem and pairs naturally with existing Prometheus-based examples. Other data sources (SQL, CloudWatch, etc.) can be added incrementally in future work without requiring structural changes to the type system.
  Date: 2026-04-10

- Decision: Add a `datasource` field with `type` and `uid` to all target types.
  Rationale: Modern Grafana v11 requires targets to include a `datasource` reference with both `type` (e.g., "prometheus") and `uid` (the data source's unique identifier). The current types either lack this field or use a simple string. The modern format is `{ type : Text, uid : Text }`. This is needed for mixed data source panels and the modern provisioning model.
  Date: 2026-04-10

- Decision: Support both InfluxQL and Flux in the InfluxDB target rather than creating separate types.
  Rationale: Grafana's InfluxDB data source supports both query languages through the same data source configuration, distinguished by a `query` field (Flux) versus `measurement`/`select`/`groupBy` fields (InfluxQL). A single type with optional fields for each query model is more ergonomic than separate types, since users select the language at the data source level, not per query.
  Date: 2026-04-10

- Decision: InfluxDB support subsequently removed entirely.
  Rationale: InfluxDB is not used in this project. Carrying the types and defaults added
  maintenance burden. Removed in EP-5 (docs/plans/5-remove-influxdb-support.md).
  Date: 2026-04-10


## Outcomes & Retrospective

All goals achieved. The data source target types now reflect the modern Grafana v11 query model:

- **PrometheusTarget**: Added `editorMode` (code/builder), `range` (Bool), `datasource` (Optional DatasourceRef). Changed `legendFormat` to `Text` (default `"__auto"`), `interval` to `Optional Text`. All existing examples compile.
- **InfluxTarget**: Added `datasource`, `query` (Optional Text for Flux), `language` (Optional Text). Both InfluxQL and Flux query modes work within a single type.
- **TestDataDBTarget** and **RawQueryTarget**: Added `datasource` field.
- **LokiTarget**: New type with `editorMode`, `expr`, `queryType` (range/instant), `legendFormat`, `maxLines`, `datasource`. Added to MetricTargets union.
- **DatasourceRef**: Shared `{ type : Text, uid : Text }` type used by all targets.
- **package.dhall**: Exports LokiTarget, DatasourceRef, EditorMode and QueryType enums.

All five example dashboards compile. LokiTarget standalone expression produces correct JSON. InfluxDB Flux query target verified.


## Context and Orientation

This plan modifies the data source target types in dhall-grafana. It depends on the modernized core types from EP-2 (docs/plans/2-modernize-core-types.md) for the updated FieldConfig and Dashboard types.

The current target types are defined in these files:

`types/PrometheusTarget.dhall` defines the PrometheusTarget type with fields: `refId` (Text), `expr` (Text, the PromQL expression), `intervalFactor` (Natural), `format` (FormatType union of `table | time_series | heatmap`), `legendFormat` (Optional Text), `interval` (Optional Natural), `instant` (Bool), and `scenarioId` (Optional ScenarioId). It also exports a FormatType union.

`types/InfluxTarget.dhall` defines the InfluxTarget type with fields for InfluxQL queries: `groupBy` (list of InfluxGroup records), `select` (nested list of InfluxGroup), `measurement` (Text), `orderByTime` (Text), `policy` (Text), `resultFormat` (Text), `refId` (Text), `tags` (list of InfluxTag), and `alias` (Text). InfluxGroup is `{ params : List Text, type : Text }` and InfluxTag is `{ key : Text, operator : Text, value : Text }`.

`types/TestDataDBTarget.dhall` defines the TestDataDBTarget type with `refId` and `scenarioId` fields. It also exports a ScenarioId union with 14 test data scenario variants.

`types/RawQueryTarget.dhall` defines a generic raw query target with `hide`, `queryType`, `rawQuery`, and `refId`.

`types/MetricTargets.dhall` defines the MetricTargets union that encompasses all target types: `PrometheusTarget`, `InfluxTarget`, `TestDataDBTarget`, `RawQueryTarget`, plus `LuceneTarget` (defined in `schemas/LuceneTarget.dhall`).

Default values for each target type are in `defaults/PrometheusTarget.dhall`, `defaults/InfluxTarget.dhall`, `defaults/TestDataDBTarget.dhall`, and `defaults/RawQueryTarget.dhall`.

In modern Grafana v11, query targets have evolved. A PrometheusTarget now includes: `datasource` (record with `type: "prometheus"` and `uid`), `editorMode` (union of `code | builder`, corresponding to the raw PromQL editor or visual query builder), `expr` (the PromQL expression), `legendFormat` (Text with `__auto` as the modern default instead of None), `range` (Bool, whether this is a range query), `instant` (Bool, whether this is an instant query), `refId` (Text), `format` (now includes additional options), and `interval` (Text, not Natural, representing the minimum step like "15s"). The `intervalFactor` field is deprecated.

A LokiTarget in Grafana v11 has: `datasource` (record with `type: "loki"` and `uid`), `editorMode` (code | builder), `expr` (the LogQL expression), `queryType` (range | instant), `refId` (Text), `legendFormat` (Optional Text), and `maxLines` (Natural, maximum log lines to return).

Modern InfluxDB targets support Flux queries via: `datasource` (record with `type: "influxdb"` and `uid`), `query` (Text, the Flux query), `refId` (Text), and `resultFormat` (time_series | table | logs). The existing InfluxQL fields remain valid when the data source is configured for InfluxQL mode.


## Plan of Work

This plan has two milestones. The first modernizes existing target types (PrometheusTarget, InfluxTarget) and adds the datasource field pattern. The second adds the LokiTarget, updates MetricTargets and package.dhall, and validates everything.


### Milestone 1: Modernize Existing Target Types

After this milestone, PrometheusTarget and InfluxTarget match the modern Grafana v11 query model, and all targets include a datasource reference field.

Define a shared DatasourceRef type. This is a simple record `{ type : Text, uid : Text }` used by all targets to reference their data source. Create `types/DatasourceRef.dhall` for this type and `defaults/DatasourceRef.dhall` with a default (type and uid as empty strings, to be filled by users).

Edit `types/PrometheusTarget.dhall` to add these fields: `datasource` (Optional DatasourceRef, optional for backward compatibility), `editorMode` (EditorMode union of `code | builder`), `range` (Bool), and `legendFormat` changes from `Optional Text` to `Text` with default `"__auto"`. The `intervalFactor` field should remain for backward compatibility but the default can note it is deprecated. The `interval` field type should be `Optional Text` (e.g., "15s") instead of `Optional Natural`. The `format` union (FormatType) should be expanded if needed.

Update `defaults/PrometheusTarget.dhall` to reflect modern defaults: `editorMode = EditorMode.code`, `range = True`, `instant = False`, `legendFormat = "__auto"`, `datasource = None DatasourceRef`.

Edit `types/InfluxTarget.dhall` to add: `datasource` (Optional DatasourceRef), `query` (Optional Text, for Flux queries), and `language` (Optional Text, "influxql" or "flux" to indicate query mode). The existing InfluxQL fields (`measurement`, `select`, `groupBy`, etc.) remain as Optional to support both modes. When `query` is provided and `language` is "flux", the InfluxQL fields are ignored.

Update `defaults/InfluxTarget.dhall` accordingly, preserving the existing InfluxQL defaults and adding `query = None Text`, `language = None Text`, `datasource = None DatasourceRef`.

Add `datasource` (Optional DatasourceRef) to `types/TestDataDBTarget.dhall` and `types/RawQueryTarget.dhall` as well, with `None DatasourceRef` as default.

Acceptance: compile the existing influxdb.dhall and consul_exporter.dhall examples. They should still work with the updated types (new fields are Optional with defaults of None). Inspect the JSON to verify the structure is valid.


### Milestone 2: Add LokiTarget, Update MetricTargets, and Validate

After this milestone, LokiTarget is available, MetricTargets includes it, and package.dhall exports all new and updated types.

Create `types/LokiTarget.dhall` defining the LokiTarget type with fields: `datasource` (Optional DatasourceRef), `editorMode` (EditorMode union of `code | builder`), `expr` (Text, the LogQL expression), `queryType` (QueryType union of `range | instant`), `refId` (Text), `legendFormat` (Optional Text), and `maxLines` (Natural, default 1000).

Create `defaults/LokiTarget.dhall` with sensible defaults: `editorMode = code`, `queryType = range`, `expr = ""`, `refId = "A"`, `legendFormat = None Text`, `maxLines = 1000`, `datasource = None DatasourceRef`.

Edit `types/MetricTargets.dhall` to add `LokiTarget` to the union. The union should now have six variants: `PrometheusTarget`, `InfluxTarget`, `TestDataDBTarget`, `RawQueryTarget`, `LuceneTarget`, and `LokiTarget`.

Edit `package.dhall` to add exports for: `LokiTarget` (Type and default), `DatasourceRef` (Type and default). Update the `PrometheusTarget` and `InfluxTarget` exports if their structure changed (e.g., if new enums like EditorMode are exported separately).

Optionally, if time permits and a Loki instance is available for testing, add a Loki data source to the process-compose setup and create an example dashboard using LokiTarget. If Loki is not practical for the test environment, create a validation Dhall expression that compiles a LokiTarget to JSON and manually verify the structure matches Grafana's expectations.

Acceptance: `just build` compiles all example dashboards without errors. The MetricTargets union accepts LokiTarget values. A test expression like the following compiles to valid JSON:

    let G = ./package.dhall
    in  G.MetricsTargets.LokiTarget
          (G.LokiTarget.default // { expr = "{job=\"grafana\"}" })

The resulting JSON should have `"datasource"`, `"expr"`, `"queryType"`, `"editorMode"`, and `"refId"` fields.


## Concrete Steps

Working directory: `/Users/shinzui/Keikaku/bokuno/dhall-grafana`

After modifying PrometheusTarget, verify backward compatibility:

    dhall-to-json --file examples/consul_exporter.dhall > /dev/null && echo "OK"

Expected: OK (no type errors).

After adding LokiTarget, test a standalone expression:

    echo 'let G = ./package.dhall in G.MetricsTargets.LokiTarget (G.LokiTarget.default // { expr = "{job=\"grafana\"}" })' | dhall-to-json | jq .

Expected output should include:

    {
      "datasource": null,
      "editorMode": "code",
      "expr": "{job=\"grafana\"}",
      "queryType": "range",
      "refId": "A",
      "legendFormat": null,
      "maxLines": 1000
    }

Build all examples:

    just build

All should succeed.


## Validation and Acceptance

All existing example dashboards must compile without errors after the target type changes, confirming backward compatibility. The new fields added to PrometheusTarget and InfluxTarget should appear in the JSON output only when set to non-None values (Dhall's Optional serialization behavior).

For LokiTarget, create a test expression that constructs a Loki query and verify the JSON output matches the structure Grafana v11 expects. If a Loki data source is available in the test environment, load a panel with a Loki target and verify Grafana's query editor recognizes the query configuration.

For InfluxDB Flux support, verify that a target with `query = Some "from(bucket: \"test\")"` and `language = Some "flux"` produces JSON with the `query` field present, while the InfluxQL fields are absent or null.


## Idempotence and Recovery

All changes to existing target types are additive — new Optional fields with None defaults. Existing code that constructs targets without the new fields will continue to work unchanged because Dhall's record completion fills in defaults.

If a type change breaks an existing example, the Dhall error message will indicate exactly which field is missing or mistyped. The fix is to either update the example or adjust the type definition.

New files (LokiTarget, DatasourceRef) can be removed without affecting existing functionality since they are only referenced from MetricTargets and package.dhall.


## Interfaces and Dependencies

This plan depends on the modernized core types from EP-2 (docs/plans/2-modernize-core-types.md) for the updated Dashboard and FieldConfig types. It has a soft dependency on EP-3 (docs/plans/3-modern-panel-types.md) for using modern panel types in example dashboards, but can proceed with existing panel types.

New files created by this plan:

    types/DatasourceRef.dhall — shared data source reference type
    defaults/DatasourceRef.dhall — DatasourceRef default
    types/LokiTarget.dhall — Loki query target type
    defaults/LokiTarget.dhall — LokiTarget default

Files modified by this plan:

    types/PrometheusTarget.dhall — add datasource, editorMode, range; update interval type
    defaults/PrometheusTarget.dhall — update defaults for new fields
    types/InfluxTarget.dhall — add datasource, query (Flux), language
    defaults/InfluxTarget.dhall — update defaults for Flux support
    types/TestDataDBTarget.dhall — add datasource field
    defaults/TestDataDBTarget.dhall — add datasource default
    types/RawQueryTarget.dhall — add datasource field
    defaults/RawQueryTarget.dhall — add datasource default
    types/MetricTargets.dhall — add LokiTarget to union
    package.dhall — add LokiTarget and DatasourceRef exports
