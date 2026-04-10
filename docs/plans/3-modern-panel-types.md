# Add Modern Panel Types

Intention: intention_01knvv7t7fe6g9vnshthqzh058

MasterPlan: docs/masterplans/1-revamp-dhall-grafana.md

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `.claude/skills/exec-plan/PLANS.md`.


## Purpose / Big Picture

After this change, dhall-grafana supports the modern Grafana v11 panel types that have replaced or supplemented legacy panels. The most important addition is the TimeSeries panel, which replaced the legacy GraphPanel as the default time-series visualization in Grafana 7.4+. Additional modern panels include BarChart (grouped/stacked bar charts), PieChart (pie and donut charts), Histogram (distribution charts), StateTimeline (state changes over time), and StatusHistory (status grid over time). Each new panel type has a Dhall type definition, default values, and smart constructor functions following the existing patterns in the codebase.

To see it working: write a Dhall dashboard using `TimeSeriesPanel` instead of `GraphPanel`, compile it with `just build`, and load it into Grafana v11. The TimeSeries panel should render with modern features like gradient fills, stacking modes, and the new tooltip system.


## Progress

- [x] Add TimeSeries panel type, default, and smart constructor (2026-04-10)
- [ ] Add BarChart panel type, default, and smart constructor
- [ ] Add PieChart panel type, default, and smart constructor
- [ ] Add Histogram panel type, default, and smart constructor
- [ ] Add StateTimeline panel type, default, and smart constructor
- [ ] Add StatusHistory panel type, default, and smart constructor
- [ ] Update Panels union in types/Panels.dhall to include all new panel types
- [ ] Add panel-specific FieldConfig custom types for each new panel
- [ ] Update package.dhall with new panel exports
- [ ] Create example dashboard demonstrating modern panels
- [ ] Validate all new panels render correctly in Grafana v11


## Surprises & Discoveries

- Modern panels need a different base panel type (ModernBasePanel) because BasePanel includes `fieldConfig : Optional FieldConfig.Type` with `custom : {}`, but modern panels need panel-specific custom types inside fieldConfig.defaults.custom. Created `types/ModernBasePanel.dhall` (base fields without fieldConfig) and `types/ModernFieldConfig.dhall` (parameterized fieldConfig type constructor) to solve this cleanly.
- `barAlignment` must be `Integer` (not enum) because Grafana v11 expects JSON integer values (-1/0/1), not strings.


## Decision Log

- Decision: Prioritize TimeSeries, BarChart, PieChart, Histogram, StateTimeline, and StatusHistory as the initial set of modern panels.
  Rationale: TimeSeries is the most critical as it replaces GraphPanel. The other five cover the most commonly used visualization types in modern Grafana dashboards. More specialized panels (GeoMap, Canvas, NodeGraph, FlameGraph, Traces) can be added in a future initiative.
  Date: 2026-04-10

- Decision: Keep legacy GraphPanel and SinglestatPanel in the codebase rather than removing them.
  Rationale: Users may still target older Grafana versions or have existing dashboards using legacy panels. Removing them would break backward compatibility. They should be documented as deprecated with pointers to their modern replacements (TimeSeries and Stat respectively).
  Date: 2026-04-10

- Decision: Each panel type defines its own FieldConfig custom options type rather than using a shared one.
  Rationale: In Grafana v11, `fieldConfig.defaults.custom` varies significantly between panel types. TimeSeries has draw style, line interpolation, fill opacity. BarChart has bar alignment, grouping. PieChart has no custom field config at all. Modeling these as separate types per panel is more type-safe and matches Grafana's internal architecture.
  Date: 2026-04-10

- Decision: Created ModernBasePanel.dhall and ModernFieldConfig.dhall as shared infrastructure for modern panels.
  Rationale: BasePanel.dhall includes `fieldConfig : Optional FieldConfig.Type` with `custom : {}`, which can't be overridden via `//\\` (requires disjoint keys). ModernBasePanel omits fieldConfig so each panel can define its own typed fieldConfig. ModernFieldConfig is a type-level function `λ(Custom : Type) → ...` that parameterizes the FieldConfig defaults by the panel-specific custom type, avoiding duplication of the color/unit/thresholds/mappings structure across all six panel types.
  Date: 2026-04-10


## Outcomes & Retrospective

(To be filled during and after implementation.)


## Context and Orientation

This plan adds new panel types to the dhall-grafana library. It depends on the modernized core types from EP-2 (docs/plans/2-modernize-core-types.md), particularly the updated FieldConfig with `defaults.custom` support and modern color modes.

The current panel system is defined across several files. `types/Panels.dhall` defines the Panels union type, which currently has six variants: `TextPanel`, `GraphPanel`, `SinglestatPanel`, `StatPanel`, `TablePanel`, and `Row`. Each variant wraps a panel-specific record type. The union also defines a `Panels` type (the union itself) and includes helper functions for constructing panels.

Each panel type follows a consistent pattern. A type file in `types/` defines the panel's record type and any associated enums. A default file in `defaults/` provides default values. The `types/Panels.dhall` file includes a smart constructor function (e.g., `mkGraphPanel`, `mkStatPanel`) that merges a user-provided partial record with defaults and wraps it in the union.

The `types/BasePanel.dhall` file defines common panel fields shared by all panels: `id`, `title`, `gridPos`, `links`, `transparent`, `repeat`, `repeatDirection`, `maxPerRow`, `alert`, `transformations`, and `fieldConfig`. Every panel type includes these base fields plus its own type-specific fields.

In modern Grafana v11, panels are structured as:

    {
      "type": "timeseries",
      "title": "...",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "..." },
      "targets": [...],
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": { ...panel-specific options... },
          "thresholds": { ... }
        },
        "overrides": [...]
      },
      "options": { ...panel-specific options... }
    }

The key structural difference from the current codebase is the `options` field and the `fieldConfig.defaults.custom` field, both of which vary per panel type. The EP-2 core type modernization establishes the FieldConfig foundation; this plan provides the panel-specific custom configs and options.


## Plan of Work

This plan has three milestones. The first adds the TimeSeries panel as the most critical new type. The second adds BarChart, PieChart, and Histogram. The third adds StateTimeline and StatusHistory, updates the Panels union and package.dhall, and creates a modern example dashboard.


### Milestone 1: TimeSeries Panel

After this milestone, users can create TimeSeries panels using `Panels.mkTimeSeriesPanel` with full support for the modern visualization options.

The TimeSeries panel is the modern replacement for GraphPanel. It was introduced in Grafana 7.4 and became the default time-series visualization. Its panel type string is `"timeseries"`.

Create `types/TimeSeriesPanel.dhall` defining the TimeSeriesPanel type. The type should include the base panel fields plus: `datasource` (optional record with `type` and `uid`), `targets` (list of MetricTargets), and `options` (a TimeSeriesOptions record).

TimeSeriesOptions has these fields: `legend` (record with `calcs` as list of CalcMode values, `displayMode` as LegendDisplayMode union of `list | table | hidden`, `placement` as LegendPlacement union of `bottom | right`, `showLegend` as Bool, and `width` as Optional Natural), `tooltip` (record with `mode` as TooltipMode union of `single | multi | none`, `sort` as TooltipSort union of `none | asc | desc`, and `maxHeight` as Natural).

The panel-specific FieldConfig custom options for TimeSeries include: `drawStyle` (union of `line | bars | points`), `lineInterpolation` (union of `linear | smooth | stepBefore | stepAfter`), `lineWidth` (Natural, typically 1), `fillOpacity` (Natural, 0-100), `gradientMode` (union of `none | opacity | hue | scheme`), `showPoints` (union of `auto | always | never`), `pointSize` (Natural, typically 5), `stacking` (record with `mode` as union of `none | normal | percent` and `group` as Text), `barAlignment` (Integer, -1/0/1 for before/center/after), `spanNulls` (Bool or Natural for max gap), `axisCenteredZero` (Bool), `axisColorMode` (union of `text | series`), `axisLabel` (Text), `axisPlacement` (union of `auto | left | right | hidden`), `scaleDistribution` (record with `type` as union of `linear | log` and optional `log` as Natural for log base), and `thresholdsStyle` (record with `mode` as union of `off | line | area | line+area`).

Create `defaults/TimeSeriesPanel.dhall` with sensible defaults matching Grafana's defaults: line draw style, linear interpolation, lineWidth 1, fillOpacity 0, no gradient, auto show points, pointSize 5, no stacking, bottom legend as list, single tooltip mode.

Add the `TimeSeriesPanel` variant to the Panels union in `types/Panels.dhall` and add a `mkTimeSeriesPanel` smart constructor.

Acceptance: write a small Dhall expression that creates a TimeSeries panel, compile it with dhall-to-json, and verify the JSON matches the structure Grafana v11 expects. Load it into Grafana and verify the panel renders as a time series chart.


### Milestone 2: BarChart, PieChart, and Histogram Panels

After this milestone, three additional modern panel types are available with full type definitions and defaults.

Create `types/BarChartPanel.dhall`. The BarChart panel type string is `"barchart"`. Its options include: `orientation` (horizontal | vertical), `barWidth` (Double, 0-1), `barRadius` (Double, 0-0.5), `groupWidth` (Double, 0-1), `stacking` (none | normal | percent), `legend` (same structure as TimeSeries), `tooltip` (same structure as TimeSeries), `showValue` (auto | always | never), `xTickLabelRotation` (Integer, degrees), `xTickLabelSpacing` (Natural), and `colorByField` (Optional Text). Its custom field config includes `lineWidth`, `fillOpacity`, `gradientMode`, `axisCenteredZero`, `axisColorMode`, `axisLabel`, `axisPlacement`, `scaleDistribution`, and `hideFrom`.

Create `types/PieChartPanel.dhall`. The PieChart panel type string is `"piechart"`. Its options include: `pieType` (pie | donut), `reduceOptions` (same structure as StatPanel's reduceOptions with `calcs`, `fields`, `values`), `legend` (similar to TimeSeries but with `values` as list of CalcMode), `tooltip` (same as TimeSeries), and `displayLabels` (list of label types: name | value | percent). PieChart has minimal custom field config (just `hideFrom`).

Create `types/HistogramPanel.dhall`. The Histogram panel type string is `"histogram"`. Its options include: `bucketCount` (Optional Natural, auto if None), `bucketSize` (Optional Double), `combine` (Bool, combine series), `fillOpacity` (Natural), `gradientMode` (none | opacity | hue | scheme), `legend` (same as TimeSeries), `tooltip` (same as TimeSeries), and `stacking` (same as TimeSeries). Custom field config includes `lineWidth`, `fillOpacity`, `gradientMode`, `hideFrom`, and `axisCenteredZero`.

Create corresponding default files for each panel type in `defaults/`. Add all three variants to the Panels union with smart constructors.

Acceptance: create a test Dhall expression with one of each new panel type, compile to JSON, and verify the structure. Load into Grafana and verify each panel type is recognized and renders.


### Milestone 3: StateTimeline, StatusHistory, Integration, and Example

After this milestone, all six new panel types are integrated into the library with exports in package.dhall, and a new example dashboard demonstrates them.

Create `types/StateTimelinePanel.dhall`. The StateTimeline panel type string is `"state-timeline"`. Its options include: `mergeValues` (Bool, merge identical consecutive values), `alignValue` (left | center), `legend` (same as TimeSeries), `tooltip` (same as TimeSeries), and `rowHeight` (Double, 0-1). Custom field config includes `lineWidth`, `fillOpacity`, and `hideFrom`.

Create `types/StatusHistoryPanel.dhall`. The StatusHistory panel type string is `"status-history"`. Its options include: `showValue` (auto | always | never), `legend` (same as TimeSeries), `tooltip` (same as TimeSeries), and `rowHeight` (Double, 0-1). Custom field config includes `lineWidth`, `fillOpacity`, and `hideFrom`.

Create default files for both.

Update `types/Panels.dhall` to include all six new panel types in the union and add smart constructors for each. The Panels union should now have twelve variants: the original six (TextPanel, GraphPanel, SinglestatPanel, StatPanel, TablePanel, Row) plus the six new ones (TimeSeriesPanel, BarChartPanel, PieChartPanel, HistogramPanel, StateTimelinePanel, StatusHistoryPanel).

Update `package.dhall` to export all new panel types following the existing pattern of `{ default = ..., Type = ... }` pairs, plus a PanelType enum for each.

Create `examples/modern_panels.dhall`, a new example dashboard that demonstrates all six new panel types using the TestData DB data source. This dashboard should include one panel of each new type with representative configurations, serving both as documentation and as a validation artifact.

Acceptance: `just build` compiles all five example dashboards (the four existing plus the new modern_panels.dhall) without errors. Load modern_panels.dhall into Grafana v11 and verify all six panel types render correctly with their configured options.


## Concrete Steps

Working directory: `/Users/shinzui/Keikaku/bokuno/dhall-grafana`

After adding each panel type, verify it compiles:

    echo './types/TimeSeriesPanel.dhall' | dhall type

This should output the type signature without errors.

After updating the Panels union, verify the whole package compiles:

    echo './package.dhall' | dhall type

Build the new example:

    dhall-to-json --file examples/modern_panels.dhall | jq '.panels | length'

Expected: 6 (one of each new panel type).

Load into Grafana:

    dashboard=$(dhall-to-json --file examples/modern_panels.dhall | jq -c '{ "dashboard": ., "folderId": 0, "overwrite": true }')
    curl -s -XPOST -H "Content-Type: application/json" -d "$dashboard" http://admin:admin@localhost:3000/api/dashboards/db | jq .


## Validation and Acceptance

Run `just build` to compile all example dashboards. All must succeed without Dhall type errors. The new `modern_panels.dhall` example should produce JSON where each panel's `type` field matches the expected panel type string ("timeseries", "barchart", "piechart", "histogram", "state-timeline", "status-history").

Load the modern panels dashboard into Grafana v11 and verify each panel renders with its visualization type. Specifically: the TimeSeries panel shows a line chart with the configured draw style, the BarChart shows grouped or stacked bars, the PieChart shows a pie or donut, the Histogram shows a distribution, the StateTimeline shows colored state bands, and the StatusHistory shows a grid of status values.

Verify backward compatibility by confirming all four original example dashboards still compile and produce valid JSON.


## Idempotence and Recovery

All changes are additive — new files in `types/` and `defaults/`, new variants in the Panels union, new exports in package.dhall. No existing types are modified in a breaking way. If a new panel type causes issues, its files can be removed and the Panels union reverted without affecting the rest of the codebase.

The Panels union extension follows a well-established pattern in the codebase. If adding a variant causes a Dhall type error, the error message will indicate which existing code is incompatible with the extended union.


## Interfaces and Dependencies

This plan depends on the modernized FieldConfig from EP-2 (docs/plans/2-modernize-core-types.md), particularly the `defaults.custom` structure and expanded ColorMode union.

New files created by this plan:

    types/TimeSeriesPanel.dhall — TimeSeries panel type with options and custom field config
    defaults/TimeSeriesPanel.dhall — TimeSeries panel defaults
    types/BarChartPanel.dhall — BarChart panel type
    defaults/BarChartPanel.dhall — BarChart panel defaults
    types/PieChartPanel.dhall — PieChart panel type
    defaults/PieChartPanel.dhall — PieChart panel defaults
    types/HistogramPanel.dhall — Histogram panel type
    defaults/HistogramPanel.dhall — Histogram panel defaults
    types/StateTimelinePanel.dhall — StateTimeline panel type
    defaults/StateTimelinePanel.dhall — StateTimeline panel defaults
    types/StatusHistoryPanel.dhall — StatusHistory panel type
    defaults/StatusHistoryPanel.dhall — StatusHistory panel defaults
    examples/modern_panels.dhall — Example dashboard with all modern panel types

Files modified by this plan:

    types/Panels.dhall — add six new variants to the Panels union with smart constructors
    package.dhall — add exports for all six new panel types
