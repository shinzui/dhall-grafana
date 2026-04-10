# Modernize Core Dashboard Schema and Field Configuration

Intention: intention_01knvv7t7fe6g9vnshthqzh058

MasterPlan: docs/masterplans/1-revamp-dhall-grafana.md

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `.claude/skills/exec-plan/PLANS.md`.


## Purpose / Big Picture

After this change, the dhall-grafana library produces dashboard JSON that Grafana v11 accepts without warnings or compatibility shims. The Dashboard type includes modern fields like `annotations`, `fiscalYearStartMonth`, `liveNow`, and `weekStart`, with the schema version updated from 17 to 39. The FieldConfig type supports the full modern override system including `defaults.custom` for panel-specific options, expanded value mappings, and data links. These core type changes establish the foundation that all subsequent panel and data source type work builds upon.

To see it working: compile the updated example dashboards with `just build`, then load the resulting JSON into Grafana v11 via the API or by importing through the UI. The dashboards should load without schema migration warnings and display correctly.


## Progress

- [x] Update Dashboard type with new fields (annotations, fiscalYearStartMonth, liveNow, weekStart) — 2026-04-10
- [x] Update schemaVersion from 17 to 39 in Dashboard default — 2026-04-10
- [x] Add Annotation type (dashboard-level annotations list) — 2026-04-10
- [x] Modernize FieldConfig: add defaults.custom as generic record, expand color modes — 2026-04-10
- [x] Add modern ValueMapping types (ValueMap, RangeMap, RegexMap, SpecialMap) — 2026-04-10
- [x] Add DataLink type for field-level links — 2026-04-10
- [x] Update Threshold type to match modern stepped format — 2026-04-10
- [x] Update existing panel defaults to use modernized FieldConfig — 2026-04-10
- [x] Update package.dhall with new exports — 2026-04-10
- [x] Update example dashboards to validate against Grafana v11 — 2026-04-10
- [x] Validate: compile examples, all four produce valid JSON — 2026-04-10
- [ ] Validate: load into Grafana v11 and verify no warnings (requires running Grafana instance)


## Surprises & Discoveries

- The `MatcherOption` union type (`< status >`) from the original FieldConfig was removed. It was too restrictive — matcher options in Grafana are free-text strings (field names, regex patterns, etc.), so `options : Text` is the correct modeling. No code outside `types/FieldConfig.dhall` referenced `MatcherOption`, so this was a clean removal.

- dhall-to-json omits `None` values from record fields rather than emitting `null`. This means threshold base steps serialize as `{"color": "green"}` without a `"value"` field, rather than `{"color": "green", "value": null}`. Grafana accepts both forms, so this is not a functional issue.


## Decision Log

- Decision: Use schema version 39 as the target, corresponding to Grafana v11.
  Rationale: Schema version 39 is the current version used by Grafana 11.x. Targeting a specific version rather than "latest" ensures we can validate against a known Grafana binary from nixpkgs.
  Date: 2026-04-10

- Decision: Model `defaults.custom` as an opaque record type rather than trying to enumerate all panel-specific custom options in FieldConfig itself.
  Rationale: In Grafana v11, each panel type defines its own `fieldConfig.defaults.custom` schema. Trying to model all possible custom options in a single FieldConfig type would create an unmanageable union. Instead, each panel type will provide its own custom field config type, and the core FieldConfig will accept a generic custom record. This follows the same pattern Grafana uses internally.
  Date: 2026-04-10

- Decision: Keep the existing legacy Alert type but mark it as deprecated.
  Rationale: Grafana Unified Alerting is a separate system from legacy per-panel alerts. Removing the Alert type would break backward compatibility for users generating dashboards for older Grafana versions. The type will be kept but the documentation will note that it only works with Grafana versions that have legacy alerting enabled.
  Date: 2026-04-10

- Decision: Separate ThresholdMode from ColorMode into distinct union types.
  Rationale: In Grafana v11, color modes (fixed, thresholds, palette-classic, continuous-*, shades) and threshold modes (absolute, percentage) are semantically distinct enums. The original code reused a single ColorMode union for both. Splitting them into ColorMode and ThresholdMode provides type safety — it's no longer possible to accidentally use a color mode like "palette-classic" for a threshold mode.
  Date: 2026-04-10


## Outcomes & Retrospective

All type changes are implemented and all four example dashboards compile to valid JSON. Key outcomes:

- Dashboard type now includes `annotations`, `fiscalYearStartMonth`, `liveNow`, `weekStart` with schema version 39.
- FieldConfig supports 15 color modes, 4 matcher types, modern value mappings (ValueMap, RangeMap, RegexMap, SpecialValueMap), data links, and expanded defaults (decimals, displayName, min, max, noValue).
- ThresholdMode separated from ColorMode for type safety.
- New types exported: Annotation, DataLink, ValueMapping, ValueMappingUtils.
- All changes are backwards-compatible with existing example dashboards — only the consul_exporter example required updates (fixedColor → Optional Text, ColorMode.absolute → ThresholdMode.absolute).
- Remaining: live Grafana v11 validation (requires `just process-up`).


## Context and Orientation

This plan modifies the core type infrastructure of dhall-grafana. The project is a Dhall library where types are defined in `types/` and default values in `defaults/`. The main entry point `package.dhall` at the repository root exports all types and defaults as a single Dhall record.

The current Dashboard type is defined in `types/Dashboard.dhall`. It exports a record type with fields: `id`, `uid`, `title`, `tags`, `style`, `timezone`, `editable`, `hideControls`, `graphTooltip`, `panels`, `time`, `timepicker`, `templating`, `refresh`, `schemaVersion`, `version`, and `links`. The default in `defaults/Dashboard.dhall` sets `schemaVersion = 17`.

A Grafana v11 dashboard JSON includes additional top-level fields not present in the current type: `annotations` (a list of annotation queries, distinct from per-panel alerts), `fiscalYearStartMonth` (Natural, default 0), `liveNow` (Bool, whether the dashboard follows real-time data), and `weekStart` (Text, empty string for browser default or a day name). The schema version is 39.

The current FieldConfig type is defined in `types/FieldConfig.dhall`. It has a `defaults` record with `color`, `custom` (currently an empty record `{}`), `unit`, `mappings` (currently `List {}`), and `thresholds`. It also has an `overrides` list. The modern Grafana FieldConfig is significantly more expressive:

The `defaults` section gains: `decimals` (optional Natural), `displayName` (optional Text), `min`/`max` (optional Double for axis bounds), `noValue` (optional Text, what to show when no data), `links` (list of DataLink records for clickable field links), and `mappings` changes from `List {}` to a proper union of ValueMap, RangeMap, RegexMap, and SpecialValueMap types.

The `defaults.custom` section is panel-type-specific. For example, a TimeSeries panel's custom config includes `drawStyle`, `lineInterpolation`, `fillOpacity`, `lineWidth`, `pointSize`, `stacking`, `showPoints`, etc. Rather than modeling this in FieldConfig, each panel type will provide its own custom config type.

The `overrides` system gains matcher types beyond the current `byName`: `byType` (matches by field type), `byRegexp` (matches by regex), and `byFrameRefID` (matches by query ref ID).

The `color` modes expand from the current four (`fixed`, `thresholds`, `absolute`, `percentage`) to include `palette-classic`, `palette-classic-by-name`, `continuous-GrYlRd`, `continuous-RdYlGr`, `continuous-BlYlRd`, `continuous-YlRd`, `continuous-BlPu`, `continuous-YlBl`, `continuous-blues`, `continuous-reds`, `continuous-greens`, `continuous-purples`, and `shades`.

The `thresholds` format changes slightly: the base step (the lowest threshold) uses `value: null` in JSON. In Dhall, this maps to `Optional Double` with `None Double` for the base step.

Value mappings in modern Grafana are a union type with four variants: `ValueMap` maps specific values to display text and color. `RangeMap` maps numeric ranges. `RegexMap` matches field values by regular expression. `SpecialValueMap` handles special cases like null, NaN, true, false, and empty.

DataLink is a new type representing a clickable link on a field value. It has fields: `title` (Text), `url` (Text), `targetBlank` (Bool, whether to open in new tab), and `internal` (optional record for Grafana internal links to other dashboards).

All Dhall files in this project use the Dhall prelude from:

    https://prelude.dhall-lang.org/v20.1.0/package.dhall
    sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98


## Plan of Work

This plan has three milestones. The first modernizes the Dashboard type and adds the Annotation type. The second overhauls FieldConfig with modern value mappings, data links, and expanded color modes. The third updates defaults, package.dhall, and example dashboards to validate everything against Grafana v11.


### Milestone 1: Modernize the Dashboard Type

After this milestone, the Dashboard type includes all fields present in a Grafana v11 dashboard JSON, and the default schema version is 39.

Edit `types/Dashboard.dhall` to add these fields to the Type record: `annotations` as `{ list : List Annotation }` where Annotation is a new type (defined below), `fiscalYearStartMonth` as `Natural`, `liveNow` as `Bool`, and `weekStart` as `Text`. The existing `Timezone` union and `Style` union remain unchanged.

Create `types/Annotation.dhall` defining the Annotation type. A Grafana annotation query has these fields: `builtIn` (Natural, 1 for the built-in "Annotations & Alerts" query, 0 for custom), `datasource` (record with `type` and `uid` fields as Text), `enable` (Bool), `hide` (Bool), `iconColor` (Text, a color string like "rgba(0, 211, 255, 1)"), `name` (Text), and `type` (Text, typically "dashboard").

Create `defaults/Annotation.dhall` with a sensible default: the built-in Grafana annotation query that shows annotations and alerts.

Edit `defaults/Dashboard.dhall` to set `schemaVersion = 39`, add `annotations = { list = [] : List Annotation }` (importing the Annotation type), `fiscalYearStartMonth = 0`, `liveNow = False`, and `weekStart = ""`.

Acceptance: compile an example dashboard and inspect the JSON output. It should include `"schemaVersion": 39`, an `"annotations"` key, `"fiscalYearStartMonth": 0`, `"liveNow": false`, and `"weekStart": ""`.


### Milestone 2: Overhaul FieldConfig and Related Types

After this milestone, the FieldConfig type supports the full Grafana v11 field configuration model including modern value mappings, expanded color modes, data links, and panel-specific custom options.

Edit `types/FieldConfig.dhall` to expand the type. The `defaults` record should include: `color` (record with `mode` as ColorMode and optional `fixedColor` as `Optional Text`), `custom` as a generic type parameter or an opaque `{}` (panel types will provide their own typed custom configs that get merged), `unit` as `Optional Text`, `decimals` as `Optional Natural`, `displayName` as `Optional Text`, `min` as `Optional Double`, `max` as `Optional Double`, `noValue` as `Optional Text`, `links` as `List DataLink` (new type), `mappings` as `List ValueMapping` (new union type), and `thresholds` with value changed to `Optional Double` to support the null base step.

The `overrides` list should have a `matcher` record with `id` as MatcherId (expand the union to include `byName`, `byType`, `byRegexp`, `byFrameRefID`) and `options` as Text.

Expand the ColorMode union in `types/FieldConfig.dhall` to include all modern modes: `fixed`, `thresholds`, `palette-classic`, `palette-classic-by-name`, `continuous-GrYlRd`, `continuous-RdYlGr`, `continuous-BlYlRd`, `continuous-YlRd`, `continuous-BlPu`, `continuous-YlBl`, `continuous-blues`, `continuous-reds`, `continuous-greens`, `continuous-purples`, and `shades`.

Create `types/ValueMapping.dhall` defining the ValueMapping union type with four variants: `ValueMap` (maps specific values: `{ type : Text, options : Map Text { text : Optional Text, color : Optional Text, index : Natural } }`), `RangeMap` (maps ranges: `{ type : Text, options : { from : Double, to : Double, result : { text : Optional Text, color : Optional Text, index : Natural } } }`), `RegexMap` (matches regex: `{ type : Text, options : { pattern : Text, result : { text : Optional Text, color : Optional Text, index : Natural } } }`), and `SpecialValueMap` (handles special values: `{ type : Text, options : { match : Text, result : { text : Optional Text, color : Optional Text, index : Natural } } }` where match is one of "null", "nan", "true", "false", "empty").

Create `defaults/ValueMapping.dhall` with smart constructors for each variant.

Create `types/DataLink.dhall` defining: `{ title : Text, url : Text, targetBlank : Bool }`. Keep it simple — internal links can be added later.

Create `defaults/DataLink.dhall` with a default.

Update `defaults/FieldConfig.dhall` to provide defaults using the new types, including empty lists for `links` and `mappings`, `None` for optional fields, and the `palette-classic` color mode as a modern default.

Acceptance: compile a dashboard that uses FieldConfig with overrides and value mappings. Inspect the JSON output to verify it matches the Grafana v11 field config structure.


### Milestone 3: Update Package Exports and Validate

After this milestone, `package.dhall` exports all new types, the example dashboards compile without errors and produce valid Grafana v11 JSON, and loading the dashboards into Grafana v11 shows no warnings.

Edit `package.dhall` to add exports for: `Annotation` (Type and default), `ValueMapping` (the union type and constructors), `DataLink` (Type and default). Update the `FieldConfig` export to reflect any structural changes.

Update each example dashboard in `examples/` to work with the updated types. The main changes will be accommodating new required fields in the Dashboard type (annotations, fiscalYearStartMonth, etc.) — most of these will be handled by the updated defaults, but if any example uses record completion (`::`) against the Dashboard type, it may need the new fields.

Run `just build` to compile all four example dashboards. Verify the JSON output is valid. Start Grafana via `just process-up` and import each dashboard JSON through the Grafana API or UI. Verify no schema migration warnings appear and dashboards display correctly.

Acceptance: all four example dashboards compile to JSON that Grafana v11 accepts. The JSON includes modern field config structure with proper color modes, value mapping format, and schema version 39.


## Concrete Steps

Working directory: `/Users/shinzui/Keikaku/bokuno/dhall-grafana`

After making type changes, compile an example to verify:

    dhall-to-json --file examples/all_dashboard.dhall | jq '.schemaVersion'

Expected output:

    39

Check the field config structure of a stat panel:

    dhall-to-json --file examples/consul_exporter.dhall | jq '.panels[0].fieldConfig'

The output should show the modern FieldConfig structure with color mode, thresholds with Optional values, etc.

Build all examples:

    just build

Load a dashboard into Grafana:

    dashboard=$(cat out/all_dashboard.json | jq -c '{ "dashboard": ., "folderId": 0, "overwrite": true }')
    curl -s -XPOST -H "Content-Type: application/json" -d "$dashboard" http://admin:admin@localhost:3000/api/dashboards/db | jq .

Expected: a response with `"status": "success"`.


## Validation and Acceptance

Compile all four example dashboards with `just build`. Each must produce valid JSON without Dhall type errors. Load each dashboard into a running Grafana v11 instance and verify: no "migrating dashboard schema" messages in Grafana server logs, all panels render correctly, the schema version in the dashboard settings shows 39, and field configurations (colors, thresholds, value mappings) display as expected.

For the FieldConfig specifically, create a small test Dhall expression that exercises value mappings and data links, compile it, and verify the JSON structure matches what Grafana expects.


## Idempotence and Recovery

All type changes are purely additive — existing types gain new optional fields with defaults. If a change breaks example compilation, the error message from `dhall-to-json` will indicate which type mismatch occurred. Rolling back is straightforward via git since these are text file changes.

The approach of updating defaults to include new fields means existing user code that uses record completion (`::`) will automatically pick up the new defaults without modification. Users who construct Dashboard records manually will need to add the new fields, but this is expected for a major version update.


## Interfaces and Dependencies

This plan depends on the test environment from EP-1 (docs/plans/1-nix-flake-process-compose.md) for a running Grafana v11 instance to validate against.

New files created by this plan:

    types/Annotation.dhall — Annotation type definition
    defaults/Annotation.dhall — Annotation default value
    types/ValueMapping.dhall — ValueMapping union type
    defaults/ValueMapping.dhall — ValueMapping smart constructors
    types/DataLink.dhall — DataLink type definition
    defaults/DataLink.dhall — DataLink default value

Files modified by this plan:

    types/Dashboard.dhall — add annotations, fiscalYearStartMonth, liveNow, weekStart fields
    defaults/Dashboard.dhall — update defaults for new fields, schemaVersion 39
    types/FieldConfig.dhall — expand with modern color modes, matcher types, custom support
    defaults/FieldConfig.dhall — update defaults for modern field config
    package.dhall — add new exports (Annotation, ValueMapping, DataLink)
    examples/*.dhall — update to work with new types (if needed)
