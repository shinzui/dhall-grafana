# Remove InfluxDB Support

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `.claude/skills/exec-plan/PLANS.md`.


## Purpose / Big Picture

After this change, all InfluxDB-specific types, defaults, examples, and exports are removed
from dhall-grafana. The project no longer carries InfluxDB support — the MetricTargets union,
package.dhall, documentation, and examples reflect only the actively used data source targets
(Prometheus, Loki, TestDataDB, RawQuery, Lucene).

To see it working: run `just build` — all remaining example dashboards compile without errors.
The `package.dhall` no longer exports `InfluxTarget`, and `MetricTargets` no longer includes
an `InfluxTarget` variant. The influxdb.dhall example and its compiled output are gone.


## Progress

- [x] Delete InfluxDB type, default, example, and compiled output files (2026-04-10)
- [x] Remove InfluxTarget from `types/MetricTargets.dhall` (2026-04-10)
- [x] Remove InfluxTarget export from `package.dhall` (2026-04-10)
- [x] Update `README.md` — remove InfluxDB from capabilities and examples table (2026-04-10)
- [x] Update `docs/plans/4-modernize-datasource-targets.md` — record InfluxDB removal (2026-04-10)
- [x] Update `docs/masterplans/1-revamp-dhall-grafana.md` — mark InfluxDB item as removed (2026-04-10)
- [x] Validate: `just build` succeeds, no remaining InfluxDB references in source files (2026-04-10)


## Surprises & Discoveries

(None yet.)


## Decision Log

- Decision: Remove InfluxDB support entirely rather than continuing to maintain it.
  Rationale: The user does not use InfluxDB. Carrying the types and defaults adds maintenance
  burden (EP-4 already invested in Flux support that will never be used). The RawQueryTarget
  type remains available as an escape hatch for arbitrary data source queries if needed in the
  future.
  Date: 2026-04-10

- Decision: Do not update EP-4's Intention or re-scope it — simply record the removal as a
  follow-up decision in EP-4's Decision Log.
  Rationale: EP-4 is already marked complete for its InfluxDB items. This plan is the
  authoritative record of the removal.
  Date: 2026-04-10


## Outcomes & Retrospective

Completed in a single pass. 4 files deleted, 5 files edited. `just build` succeeds for all
remaining examples. Zero InfluxDB references remain in types/, defaults/, examples/, or
package.dhall. The removal was clean — no surprises or cascading breakage, confirming that
InfluxDB support was well-isolated.


## Context and Orientation

dhall-grafana provides type-safe Grafana dashboards-as-code using Dhall. Data source targets
are defined as a union type (`MetricTargets`) with per-target type definitions, defaults, and
exports through `package.dhall`.

InfluxDB support currently consists of:

**Type definition** — `types/InfluxTarget.dhall` defines the `InfluxTarget` record type along
with helper types `InfluxGroup` (`{ params : List Text, type : Text }`) and `InfluxTag`
(`{ key : Text, operator : Text, value : Text }`). The target supports both InfluxQL fields
(`measurement`, `select`, `groupBy`, `tags`, etc.) and modern fields (`query`, `language`,
`datasource`) added in EP-4.

**Default values** — `defaults/InfluxTarget.dhall` provides defaults: `orderByTime = "DESC"`,
`resultFormat = "time_series"`, `policy = "default"`, and `None` for optional fields.

**Union membership** — `types/MetricTargets.dhall` imports `InfluxTarget` (line 3) and
includes `| InfluxTarget : InfluxTarget` in the union (line 14). The union currently has six
variants: PrometheusTarget, InfluxTarget, TestDataDBTarget, RawQueryTarget, LuceneTarget,
LokiTarget.

**Package export** — `package.dhall` exports `InfluxTarget` at lines 79–82:
```dhall
, InfluxTarget =
  { default = ./defaults/InfluxTarget.dhall
  , Type = (./types/InfluxTarget.dhall).Type
  }
```

**Example dashboard** — `examples/influxdb.dhall` demonstrates InfluxQL queries against the
NOAA water database. It is compile-only (no running InfluxDB needed). Its compiled output
lives at `out/influxdb.json`.

**Documentation** — `README.md` lists InfluxDB in the "Data source targets" line (line 24) and
in the examples table (line 139). `docs/plans/4-modernize-datasource-targets.md` documents
the Flux support addition. `docs/masterplans/1-revamp-dhall-grafana.md` includes an EP-4
checklist item about InfluxDB modernization (line 80).

No other files import or reference InfluxTarget — no infrastructure configs, Justfile, or CI
files depend on it. All other example dashboards use Prometheus or TestDataDB targets
exclusively.


## Plan of Work

This is a single-milestone plan — the changes are small, interdependent, and can be validated
together.

### Milestone 1: Remove All InfluxDB Support

**Delete files** (4 files):
- `types/InfluxTarget.dhall` — type definition
- `defaults/InfluxTarget.dhall` — default values
- `examples/influxdb.dhall` — example dashboard
- `out/influxdb.json` — compiled output

**Edit `types/MetricTargets.dhall`** — remove two lines:
- Line 3: `let InfluxTarget = (./InfluxTarget.dhall).Type`
- Line 14: `| InfluxTarget : InfluxTarget`

After edit, the file should define five let-bindings (PrometheusTarget, TestDataDBTarget,
RawQueryTarget, LuceneTarget, LokiTarget) and a five-variant union.

**Edit `package.dhall`** — remove lines 79–82:
```dhall
, InfluxTarget =
  { default = ./defaults/InfluxTarget.dhall
  , Type = (./types/InfluxTarget.dhall).Type
  }
```

**Edit `README.md`**:
- Line 24: change `Prometheus, InfluxDB, TestDataDB, RawQuery` to
  `Prometheus, Loki, TestDataDB, RawQuery`
- Line 139: remove the entire row
  `| [influxdb.dhall](examples/influxdb.dhall) | InfluxDB query example (compile-only, no running InfluxDB needed) |`

**Edit `docs/plans/4-modernize-datasource-targets.md`** — add a Decision Log entry recording
that InfluxDB support was subsequently removed, with a cross-reference to this plan.

**Edit `docs/masterplans/1-revamp-dhall-grafana.md`** — update line 80 to mark the InfluxDB
item as removed rather than a pending task: change the checklist item text to reflect that
InfluxDB support was removed per EP-5.

Acceptance: `just build` succeeds. `grep -ri influx types/ defaults/ examples/ package.dhall`
returns no matches.


## Concrete Steps

Working directory: `/Users/shinzui/Keikaku/bokuno/dhall-grafana`

Delete the InfluxDB files:

    rm types/InfluxTarget.dhall defaults/InfluxTarget.dhall examples/influxdb.dhall out/influxdb.json

Edit `types/MetricTargets.dhall`, `package.dhall`, `README.md`, EP-4, and the masterplan as
described in the Plan of Work section.

Validate that all remaining examples compile:

    just build

Expected: all dashboards compile to `out/` without errors. `out/influxdb.json` is no longer
generated.

Verify no stale references remain:

    grep -ri influx types/ defaults/ examples/ package.dhall

Expected: no output (zero matches).


## Validation and Acceptance

1. `just build` succeeds — all remaining example dashboards compile to JSON.
2. `grep -ri influx types/ defaults/ examples/ package.dhall` returns zero matches.
3. `types/MetricTargets.dhall` defines exactly five union variants: PrometheusTarget,
   TestDataDBTarget, RawQueryTarget, LuceneTarget, LokiTarget.
4. `package.dhall` does not export InfluxTarget.
5. `README.md` no longer mentions InfluxDB in the capabilities list or examples table.
6. The deleted files no longer exist: `types/InfluxTarget.dhall`,
   `defaults/InfluxTarget.dhall`, `examples/influxdb.dhall`, `out/influxdb.json`.


## Idempotence and Recovery

All changes are deletions or edits to existing files. If something goes wrong, `git checkout`
restores the prior state. The removal is safe because no other source files import
`InfluxTarget` — the only consumer was `types/MetricTargets.dhall` and `package.dhall`, both
of which are edited in this plan. The `examples/influxdb.dhall` example is self-contained and
has no downstream dependents.


## Interfaces and Dependencies

This plan has no external dependencies. It removes interfaces rather than adding them.

Files deleted by this plan:

    types/InfluxTarget.dhall
    defaults/InfluxTarget.dhall
    examples/influxdb.dhall
    out/influxdb.json

Files modified by this plan:

    types/MetricTargets.dhall — remove InfluxTarget from union
    package.dhall — remove InfluxTarget export
    README.md — remove InfluxDB from capabilities and examples
    docs/plans/4-modernize-datasource-targets.md — add removal decision to Decision Log
    docs/masterplans/1-revamp-dhall-grafana.md — update EP-4 InfluxDB checklist item
