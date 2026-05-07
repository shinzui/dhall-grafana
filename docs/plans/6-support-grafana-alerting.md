# Support Grafana Alerting

Intention: intention_01kr07bhfnee4t8gkh9jfy0g7d

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document is maintained in accordance with `claude/skills/exec-plan/PLANS.md`.


## Purpose / Big Picture

After this change, dhall-grafana can generate Grafana Unified Alerting provisioning files from
Dhall. A user can define alert rule groups, contact points, notification policies, mute timings,
and notification templates in typed Dhall records, compile them to JSON, and load them into the
local Grafana instance through Grafana's file provisioning system.

This matters because modern Grafana alerting is no longer a field on dashboard panels. Grafana
Unified Alerting stores alert rules and notification routing as standalone resources. Today this
repository supports dashboard JSON only; after this plan, alerting resources become a first-class
as-code surface beside dashboards.

To see it working at the end: run `just build-alerting`, start Grafana with `just process-up`,
and open `http://localhost:3000/alerting/list`. Grafana should show a provisioned alert rule from
the example Dhall file. Open `http://localhost:3000/alerting/notifications` and Grafana should show
the provisioned contact point, notification policy, mute timing, and template resources.


## Progress

- [x] Create alerting Dhall types and defaults (2026-05-07)
- [x] Export alerting API from `package.dhall` (2026-05-07)
- [x] Add example alerting provisioning files (2026-05-07)
- [x] Add build, validate, and reload commands for alerting resources (2026-05-07)
- [x] Enable Grafana Unified Alerting in local `grafana/grafana.ini` and confirm
      `/api/v1/provisioning/alert-rules` is reachable on a freshly started instance
      (2026-05-07)
- [x] Add Grafana provisioning directory and local reload documentation (2026-05-07)
- [x] Validate alerting resources against a live Grafana instance (2026-05-07)
- [x] Update README capabilities and project structure (2026-05-07)


## Surprises & Discoveries

- The existing revamp masterplan explicitly excluded Grafana Unified Alerting because it is a
  separate model from legacy per-panel alerts. That means this plan should not add alerting fields
  to `types/Dashboard.dhall` or panel types.

- Grafana file provisioning for alerting supports JSON as well as YAML. This is important because
  the current repository already compiles Dhall to JSON with `dhall-to-json`; no YAML compiler is
  required.

- Grafana's alert rule `data[].model` field is datasource-specific and is easiest to obtain by
  exporting a working rule from Grafana. The first implementation should model this field as a
  flexible JSON value rather than trying to fully type every Prometheus, Loki, and expression query
  shape immediately.

- The Grafana binary bundled by `flake.nix` (via `pkgs.grafana` from `nixpkgs-unstable`) is
  Grafana 12.4.2 at the time of this revision. Grafana 12 ships Unified Alerting as the only
  alerting system; legacy per-panel alerting was removed in Grafana 11. Unified Alerting is enabled
  by default, so no extra package or plugin is required. The plan still sets `[unified_alerting]`
  explicitly in `grafana/grafana.ini` so the local configuration documents intent and is robust to
  future upstream default changes.

- The repository's `grafana/grafana.ini` currently configures only `[auth.anonymous]`, `[paths]`,
  and `[security]`. It does not mention alerting at all. Adding an explicit `[unified_alerting]`
  block and creating an empty `grafana/provisioning/alerting/` directory before first launch
  ensures Grafana finds the provisioning location it expects and exposes
  `/api/v1/provisioning/*` endpoints on `localhost:3000`.

- During live validation on Grafana 12.4.2, provisioning failed when policy `object_matchers` were
  encoded as records:

      failure parsing policies: json: cannot unmarshal object into Go struct field Route.routes.object_matchers of type definition.ObjectMatcherAPIModel

  The accepted API shape is a list of three-item matcher tuples such as
  `[ [ "team", "=", "example" ] ]`.

- During live validation on Grafana 12.4.2, provisioning failed when the root notification policy
  used `receiver = "grafana-default-email"` because this local instance does not provision that
  contact point:

      Invalid format of the submitted route: receiver 'grafana-default-email' does not exist.

  The example now uses the provisioned `example_webhook` contact point as both the root receiver
  and the child route receiver.

- Grafana scans every file in `grafana/provisioning/alerting/` and logs a warning for `.gitkeep`
  because only `.yaml`, `.yml`, and `.json` suffixes are accepted. The warning does not block
  provisioning; `alerting.json` was accepted and all resources were returned by the provisioning
  API with `provenance = "file"`.


## Decision Log

- Decision: Implement Unified Alerting as a new top-level provisioning API, not as dashboard or
  panel fields.
  Rationale: Modern Grafana alert rules, contact points, notification policies, mute timings, and
  templates are standalone resources. Adding them to `types/Dashboard.dhall` would model the legacy
  alerting system and would conflict with the direction recorded in
  `docs/masterplans/1-revamp-dhall-grafana.md`.
  Date: 2026-05-06

- Decision: Compile Dhall alerting resources to JSON and provision those JSON files from
  `grafana/provisioning/alerting/`.
  Rationale: Grafana accepts JSON provisioning files for alerting resources, and this project
  already uses `dhall-to-json` for dashboard generation. Staying with JSON avoids introducing a new
  Dhall-to-YAML dependency.
  Date: 2026-05-06

- Decision: Type the stable envelope of alerting resources strongly, but keep rule query models and
  receiver settings flexible in the first version.
  Rationale: The stable envelope contains fields such as rule group name, folder, interval, rule
  UID, condition, labels, annotations, contact point name, receiver UID, and policy routing. The
  nested query `model` and contact point `settings` objects vary by datasource or integration, and
  Grafana recommends exporting working examples. A flexible JSON value gets useful alerting support
  working now while leaving room for typed helpers later.
  Date: 2026-05-06

- Decision: Explicitly enable Unified Alerting in `grafana/grafana.ini` rather than relying on
  Grafana's built-in default of `enabled = true`.
  Rationale: The local `grafana.ini` is short and human-readable; it currently says nothing about
  alerting. A future Grafana version, fork, or downstream packaging could change the default, and
  we want validation to be deterministic. Adding a small `[unified_alerting]` block makes the
  local environment self-documenting and removes any guesswork during onboarding.
  Date: 2026-05-07

- Decision: Treat a successful HTTP response from
  `GET /api/v1/provisioning/alert-rules` (200 OK with an empty JSON array) as the pre-flight
  signal that Grafana's alerting system is "installed and reachable" locally, before loading any
  Dhall-generated provisioning file.
  Rationale: This endpoint is exposed by Grafana only when Unified Alerting is enabled. If the
  endpoint is reachable on a freshly started instance with no provisioning file present, we know
  the alerting subsystem is healthy and any later failure must be in the Dhall-generated file or
  in the provisioning reload, not in Grafana itself. This separates the "is alerting installed"
  question from the "is the example correct" question.
  Date: 2026-05-07

- Decision: Use a pragmatic expression-rule model and text key/value settings in the first
  `types/Alerting.dhall` implementation instead of a fully recursive arbitrary JSON value.
  Rationale: Dhall-to-JSON already converts `List { mapKey, mapValue }` to JSON objects, which
  covers labels, annotations, and webhook receiver settings. The first example uses Grafana's
  built-in `__expr__` datasource, so a typed `ExpressionModel` gives a working, validated example
  without pretending to model every datasource-specific query body.
  Date: 2026-05-07

- Decision: Keep `examples/alerting.dhall` out of the normal `just build` dashboard loop.
  Rationale: The alerting example compiles to a Grafana alerting provisioning file, not a
  dashboard document. Excluding it from `just build` preserves existing dashboard validation while
  `just build-alerting` writes the file to Grafana's alerting provisioning directory.
  Date: 2026-05-07

- Decision: Represent policy `object_matchers` as `List (List Text)` and make the example root
  notification policy use `example_webhook`.
  Rationale: Grafana 12.4.2 rejected record-shaped matchers and rejected a policy that referenced
  a non-existent default email receiver. The tuple matcher shape and locally provisioned receiver
  were accepted by Grafana's file provisioning and returned by the provisioning API.
  Date: 2026-05-07


## Outcomes & Retrospective

Implemented on 2026-05-07. dhall-grafana now exposes `Grafana.Alerting.default`,
`Grafana.Alerting.Type`, and helper alert state unions. The repository contains a working
`examples/alerting.dhall` file that builds to
`grafana/provisioning/alerting/alerting.json`; Grafana 12.4.2 loaded that file and returned the
example alert rule, contact point, notification policy, mute timing, and template from the
`/api/v1/provisioning/*` endpoints with `provenance = "file"`.

Validation evidence included:

    $ just validate-alerting
    dhall type --file types/Alerting.dhall
    dhall-to-json --file examples/alerting.dhall >/dev/null

    $ just build-alerting
    dhall-to-json --file examples/alerting.dhall > grafana/provisioning/alerting/alerting.json

    $ just check-alerting-installed
    /api/v1/provisioning/alert-rules -> 200
    /api/v1/provisioning/contact-points -> 200
    /api/v1/provisioning/policies -> 200
    /api/v1/provisioning/mute-timings -> 200
    /api/v1/provisioning/templates -> 200
    Unified Alerting is installed and reachable.

    $ just reload-alerting
    {"message":"Alerting config reloaded"}


## Context and Orientation

dhall-grafana currently models Grafana dashboards. The public API is exported from
`package.dhall`. Types live under `types/`, defaults live under `defaults/`, examples live under
`examples/`, and compiled dashboard JSON is written to `out/` by the `just build` command in
`Justfile`.

Grafana provisioning means Grafana reads configuration files from a directory at startup or during
a reload request. This repository already uses dashboard provisioning through
`grafana/provisioning/dashboards/default.yaml`, which points Grafana at the compiled dashboard JSON
files under `out/`. Datasources are provisioned from `grafana/provisioning/datasources/`.

Grafana Unified Alerting is Grafana's current alerting system. It has these resource kinds:

Alert rule group: a named group of alert rules evaluated on a schedule. A group has a folder name,
an evaluation interval such as `60s`, and a list of alert rules.

Alert rule: one alert condition. A rule has a unique `uid`, a visible `title`, a `condition` refId
such as `C`, query or expression `data`, states for no-data and execution-error cases, labels used
for routing, and annotations used for human-readable context.

Contact point: a destination for alert notifications. Examples include webhook, email, Slack,
PagerDuty, and Grafana Alertmanager. In the provisioning file, a contact point contains one or more
receivers.

Receiver: one integration inside a contact point. It has a unique `uid`, a `type` such as `webhook`
or `email`, a `settings` object whose fields depend on the receiver type, and a
`disableResolveMessage` flag.

Notification policy: the routing tree that decides which contact point receives an alert. Grafana
treats this as one tree per organization. Provisioning the policy tree replaces the whole tree for
that organization, so this plan must document that behavior clearly.

Mute timing: a named time interval when matching notification policies are muted.

Notification template: a named group of Go-template text used by contact points to customize
notification titles and messages.

This plan intentionally does not modify `types/Dashboard.dhall`, `types/BasePanel.dhall`, or panel
types. Those files remain focused on dashboards.


## Plan of Work

### Milestone 1: Define Alerting Resource Types

Create a new type module at `types/Alerting.dhall`. This file defines the provisioning-file shape
that Grafana reads. The top-level type should include `apiVersion : Natural` and optional or empty
lists for every supported resource collection:

    groups
    deleteRules
    contactPoints
    deleteContactPoints
    policies
    resetPolicies
    muteTimes
    deleteMuteTimes
    templates
    deleteTemplates

Use ordinary Dhall records and unions. Keep string enums as Dhall unions where the values are known
and stable. For example, no-data state should be represented as a union with alternatives for
`NoData`, `Alerting`, and `OK`. Execution-error state should be represented as a union with
alternatives for `Error`, `Alerting`, and `OK`. Durations should be `Text` values such as `60s`,
`5m`, or `4h`, because Grafana provisioning files use duration strings.

Add a small JSON-like value type for fields that must remain flexible in the first implementation.
This type should be able to represent null, booleans, numbers, strings, arrays, and objects. Dhall
does not have arbitrary untyped JSON records, so define a recursive union with clear constructors
such as `Null`, `Bool`, `Double`, `Text`, `List`, and `Object`. If Dhall recursion makes a fully
generic JSON value awkward, choose a pragmatic narrower type for the first version: use
`List { mapKey : Text, mapValue : Text }` for receiver settings and use a raw query model type
specific to the initial example. Record the tradeoff in the Decision Log before implementation.

Create `defaults/Alerting.dhall` with an empty provisioning file:

    { apiVersion = 1
    , groups = [] : List ...
    , deleteRules = [] : List ...
    , contactPoints = [] : List ...
    , deleteContactPoints = [] : List ...
    , policies = [] : List ...
    , resetPolicies = [] : List Natural
    , muteTimes = [] : List ...
    , deleteMuteTimes = [] : List ...
    , templates = [] : List ...
    , deleteTemplates = [] : List ...
    }

Acceptance for this milestone: `dhall type --file types/Alerting.dhall` succeeds, and
`dhall-to-json --file defaults/Alerting.dhall` emits JSON with `apiVersion: 1` and empty lists.


### Milestone 2: Export the Alerting API

Edit `package.dhall` to export the new alerting module in the same style as existing exports:

    , Alerting =
      { default = ./defaults/Alerting.dhall
      , Type = (./types/Alerting.dhall).Type
      }

If `types/Alerting.dhall` exposes helper unions such as no-data state, execution-error state,
matcher operators, or receiver types, also export them under names that are easy for users to find.
Use existing package style as the guide: `PrometheusEditorMode`, `LokiQueryType`, and
`PrometheusTargetFormat` are examples of helper exports.

Acceptance for this milestone: a temporary Dhall expression can import `./package.dhall` and type
check `Grafana.Alerting.default`.

    dhall <<< 'let Grafana = ./package.dhall in Grafana.Alerting.default'

The expected output should be the empty alerting provisioning record from `defaults/Alerting.dhall`.


### Milestone 3: Add a Working Example

Create `examples/alerting.dhall`. This example should be intentionally small and should use only
local services that already exist in the development environment. The best first example is a
Grafana expression rule because the `__expr__` datasource is built into Grafana and does not depend
on external metrics. The rule can evaluate a math expression that is always false or always true.
For a useful visible demo, create one rule that fires after a short duration.

The example should include:

An alert rule group named `example_rule_group` in folder `Examples`, evaluated every `60s`.

One alert rule with `uid = "example_alert_rule"`, title `Example Always Firing Alert`, condition
`A`, and a short `for` duration such as `60s`.

Rule `data` using the Grafana expression datasource `__expr__`. The query model should follow the
shape Grafana exports for expression rules. If the exact shape is uncertain, create the rule in the
local Grafana UI once, export it in provisioning JSON, and translate the exported JSON into Dhall.

Labels such as `team = "example"` and `severity = "warning"`.

Annotations such as `summary = "Example alert generated by dhall-grafana"`.

A webhook contact point named `example_webhook` with one receiver. The receiver may point to
`http://localhost:59999/alerts` so that no real external service is required. The rule should still
provision even if notification delivery fails.

A notification policy that routes `team = example` alerts to `example_webhook`.

A mute timing named `example_weekend_mute` to prove the mute timing type compiles. Do not attach it
to the root notification policy because Grafana does not allow mute times on the root policy.

A notification template named `example_template`.

Acceptance for this milestone: `dhall-to-json --file examples/alerting.dhall` emits a provisioning
JSON document with `apiVersion`, `groups`, `contactPoints`, `policies`, `muteTimes`, and
`templates`.


### Milestone 4: Add Build and Provisioning Commands

Create `grafana/provisioning/alerting/.gitkeep` so the provisioning directory exists in the repo.

Edit `Justfile` to add these commands:

    build-alerting:
        mkdir -p grafana/provisioning/alerting
        dhall-to-json --file examples/alerting.dhall > grafana/provisioning/alerting/alerting.json

    validate-alerting:
        dhall type --file types/Alerting.dhall
        dhall-to-json --file examples/alerting.dhall >/dev/null

    reload-alerting:
        curl -sS -X POST http://admin:admin@localhost:3000/api/admin/provisioning/alerting/reload

The `reload-alerting` command uses Grafana's Admin API to reload alerting provisioning files
without restarting the server. If the endpoint path differs in the Grafana version packaged by
nixpkgs, inspect Grafana's current Admin API documentation or use a restart through
`just process-down` followed by `just process-up`. Record the discovered endpoint in the Decision
Log.

Acceptance for this milestone: `just build-alerting` creates
`grafana/provisioning/alerting/alerting.json`, and `just validate-alerting` succeeds.


### Milestone 5: Enable Unified Alerting in Local Grafana

Before validating Dhall-generated alerting resources, confirm that the local Grafana process is
actually running Unified Alerting and exposing the `/api/v1/provisioning/*` endpoints. Grafana 12
(the version bundled by `flake.nix` via `pkgs.grafana` from `nixpkgs-unstable`) enables Unified
Alerting by default and has removed legacy alerting entirely, so no plugin install or feature
flag is needed. The work in this milestone is to make this configuration explicit and to perform
a one-time reachability check.

Edit `grafana/grafana.ini` and add an explicit `[unified_alerting]` block. Keep the existing
`[auth.anonymous]`, `[paths]`, and `[security]` blocks untouched. The new block should at minimum
set `enabled = true`. Optional but recommended: keep `execute_alerts = true` (the default) so
that rules are evaluated locally rather than only provisioned. Example resulting file shape:

    [auth.anonymous]
    enabled = true
    org_name = Main Org.
    org_role = Admin

    [paths]
    logs = $__env{DATA_PATH}/logs
    data = $__env{DATA_PATH}/data
    plugins = $__env{DATA_PATH}/plugins
    provisioning = $__env{CONFIG_PATH}/provisioning

    [security]
    admin_user = admin
    admin_password = admin

    [unified_alerting]
    enabled = true

Ensure the alerting provisioning directory exists so Grafana finds the path it expects on
startup. If Milestone 4 already created `grafana/provisioning/alerting/.gitkeep`, this step is a
no-op verification; otherwise create the empty directory now.

Restart Grafana so that the new `grafana.ini` takes effect:

    just process-down
    just process-up

Wait for the readiness probe to pass, then verify reachability with no provisioning file loaded
yet (or with an empty alerting configuration). Each of these endpoints should return HTTP 200
and a JSON array (possibly empty) — not 404, 401, or 501:

    curl -sS -o /dev/null -w '%{http_code}\n' \
      http://admin:admin@localhost:3000/api/v1/provisioning/alert-rules
    curl -sS -o /dev/null -w '%{http_code}\n' \
      http://admin:admin@localhost:3000/api/v1/provisioning/contact-points
    curl -sS -o /dev/null -w '%{http_code}\n' \
      http://admin:admin@localhost:3000/api/v1/provisioning/policies
    curl -sS -o /dev/null -w '%{http_code}\n' \
      http://admin:admin@localhost:3000/api/v1/provisioning/mute-timings
    curl -sS -o /dev/null -w '%{http_code}\n' \
      http://admin:admin@localhost:3000/api/v1/provisioning/templates

If any endpoint does not return 200, do not proceed to Milestone 6. Inspect
`.dev/grafana/logs/grafana.log` for messages mentioning `unified_alerting` or `alerting`, and
record any required configuration adjustments in Surprises & Discoveries before continuing.

Optionally, add a Justfile recipe so this pre-flight check is one command:

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

Acceptance for this milestone: `grafana/grafana.ini` contains a `[unified_alerting]` block,
Grafana starts cleanly with that configuration, and every endpoint listed above returns HTTP
200. If `just check-alerting-installed` is added, it exits 0.


### Milestone 6: Validate Against Grafana

This milestone presumes Milestone 5 has already confirmed that Unified Alerting is installed and
reachable on the local instance with no provisioning file loaded. The work here is to verify
that the Dhall-generated provisioning file is accepted and that the example resources show up.

Run the full local scenario from the repository root:

    just build-alerting
    just process-up

Wait until Grafana readiness passes. If Grafana was already running from Milestone 5, a fresh
restart is the simplest way to pick up the new alerting JSON file:

    just process-down
    just process-up

Otherwise, request a hot reload:

    just reload-alerting

Use Grafana's HTTP API to verify resources. Anonymous admin access is enabled for local
development, but the API examples use basic auth so they also work if anonymous access changes:

    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/alert-rules
    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/contact-points
    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/policies
    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/mute-timings
    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/templates

Expected evidence: the alert rules response contains `example_alert_rule`; the contact points
response contains `example_webhook`; the policies response routes `team = example` alerts to the
example contact point; the mute timings response contains `example_weekend_mute`; and the templates
response contains `example_template`.

Also open the Grafana UI and verify that the resources appear with a provisioned label:

    http://localhost:3000/alerting/list
    http://localhost:3000/alerting/notifications

Acceptance for this milestone: the API responses and UI confirm that Grafana loaded the resources
from `grafana/provisioning/alerting/alerting.json`.


### Milestone 7: Documentation and Final Checks

Update `README.md` to add Grafana Alerting to the capabilities section. Add a short usage snippet
showing `just build-alerting` and `just reload-alerting`. Update the project structure block to show
`grafana/provisioning/alerting/`.

If this plan is adopted as part of the masterplan, edit
`docs/masterplans/1-revamp-dhall-grafana.md` to add a new follow-up item for Grafana Alerting and
cross-reference this plan. Do not rewrite the prior decision that excluded alerting from the
earlier modernization initiative; add a new decision stating that alerting is now handled by this
separate plan.

Run final checks:

    just build
    just validate
    just build-alerting
    just validate-alerting
    nix fmt

If `nix fmt` changes files, inspect the diff and rerun the relevant validation commands.

Acceptance for this milestone: all commands succeed, documentation explains the new feature, and
the final git diff contains only alerting-related changes.


## Concrete Steps

Working directory:

    /Users/shinzui/Keikaku/bokuno/dhall-grafana

First inspect the current exports and patterns:

    sed -n '1,160p' package.dhall
    sed -n '1,160p' types/Dashboard.dhall
    sed -n '1,160p' Justfile
    cat grafana/grafana.ini

The last command confirms which configuration sections are currently set; the new
`[unified_alerting]` block must be added without disturbing the existing `[auth.anonymous]`,
`[paths]`, and `[security]` sections.

Add `types/Alerting.dhall` and `defaults/Alerting.dhall`. Keep the types in the new alerting files
so existing dashboard modules remain untouched.

Edit `package.dhall` to export `Alerting`.

Create `examples/alerting.dhall`.

Create `grafana/provisioning/alerting/.gitkeep`.

Edit `Justfile` with `build-alerting`, `validate-alerting`, `reload-alerting`, and the optional
`check-alerting-installed` recipe described in Milestone 5.

Edit `grafana/grafana.ini` to add a `[unified_alerting]` block with `enabled = true` so the
local Grafana process is configured deterministically for alerting.

Run:

    just validate-alerting
    just build-alerting

Start Grafana and confirm Unified Alerting is installed and reachable before loading the example
provisioning file:

    just process-up
    curl -sS -o /dev/null -w '%{http_code}\n' \
      http://admin:admin@localhost:3000/api/v1/provisioning/alert-rules
    # expect: 200

Then either restart Grafana so it loads `grafana/provisioning/alerting/alerting.json`, or hot
reload:

    just reload-alerting

Then inspect the provisioning API responses:

    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/alert-rules
    curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/contact-points

When validation is complete, update `README.md` and this plan's Progress, Surprises &
Discoveries, Decision Log, and Outcomes & Retrospective sections with the actual evidence observed.


## Validation and Acceptance

This plan is complete when all of the following are true:

1. `types/Alerting.dhall` and `defaults/Alerting.dhall` exist and type check.
2. `package.dhall` exports `Alerting.default` and `Alerting.Type`.
3. `examples/alerting.dhall` compiles to JSON.
4. `just build-alerting` writes `grafana/provisioning/alerting/alerting.json`.
5. `just validate-alerting` succeeds.
6. `grafana/grafana.ini` contains an explicit `[unified_alerting]` block with `enabled = true`,
   and on a freshly started local Grafana the endpoint
   `GET /api/v1/provisioning/alert-rules` returns HTTP 200 with no provisioning file loaded
   (the "Unified Alerting is installed locally" check).
7. A local Grafana instance loads the generated alerting provisioning file.
8. Grafana's alerting provisioning API returns the example alert rule, contact point, notification
   policy, mute timing, and template.
9. `README.md` documents the new alerting capability and commands.
10. Existing dashboard commands still pass: `just build` and `just validate`.

A concise success transcript should look like this:

    $ just validate-alerting
    dhall type --file types/Alerting.dhall
    dhall-to-json --file examples/alerting.dhall >/dev/null

    $ just build-alerting
    mkdir -p grafana/provisioning/alerting
    dhall-to-json --file examples/alerting.dhall > grafana/provisioning/alerting/alerting.json

    $ curl -sS http://admin:admin@localhost:3000/api/v1/provisioning/alert-rules
    ... example_alert_rule ...


## Idempotence and Recovery

The implementation should be additive. New files are added under `types/`, `defaults/`,
`examples/`, and `grafana/provisioning/alerting/`. Existing files are edited only to export the
new API, add commands, and document the feature.

If `just build-alerting` is run more than once, it overwrites
`grafana/provisioning/alerting/alerting.json` with the same generated output. This is expected and
safe.

If Grafana rejects a provisioning file, remove or move
`grafana/provisioning/alerting/alerting.json`, restart Grafana with `just process-down` and
`just process-up`, and then fix the Dhall source. Do not delete `.dev/grafana` unless stale
provisioned resources make validation impossible; if that happens, stop services first and record
the cleanup in Surprises & Discoveries.

If notification delivery to the example webhook fails, that is acceptable. The example webhook URL
is only a local placeholder. The acceptance criterion is successful provisioning and routing, not
successful delivery to an external notification system.


## Interfaces and Dependencies

New files:

    types/Alerting.dhall
    defaults/Alerting.dhall
    examples/alerting.dhall
    grafana/provisioning/alerting/.gitkeep

Modified files:

    package.dhall
    Justfile
    grafana/grafana.ini
    README.md
    docs/plans/6-support-grafana-alerting.md
    docs/masterplans/1-revamp-dhall-grafana.md, if this plan is added to the masterplan

Generated file:

    grafana/provisioning/alerting/alerting.json

External behavior:

    Grafana reads alerting provisioning files from grafana/provisioning/alerting/.
    Grafana exposes provisioned alerting resources through /api/v1/provisioning/* endpoints.

No new service or package is required. The Grafana binary supplied by `flake.nix` (currently
Grafana 12.4.2 from `nixpkgs-unstable`) ships Unified Alerting as the default and only alerting
system. The existing Grafana process in `process-compose.yaml` already reads the provisioning
directory configured by `grafana/grafana.ini`; this plan adds an alerting subdirectory under
that same root and an explicit `[unified_alerting]` block in the existing `grafana.ini`.


## Revision Notes

- 2026-05-06: Initial ExecPlan created. It scopes Grafana Unified Alerting as a separate
  provisioning domain and chooses JSON file provisioning to align with the existing Dhall build
  workflow.

- 2026-05-07: Added explicit local-installation guarantees for Grafana Unified Alerting. The
  bundled `pkgs.grafana` was identified as Grafana 12.4.2, where Unified Alerting is the default
  and only alerting system. A new Milestone 5 ("Enable Unified Alerting in Local Grafana") was
  inserted before validation to (a) add a `[unified_alerting]` block to `grafana/grafana.ini`,
  (b) ensure `grafana/provisioning/alerting/` exists, and (c) confirm reachability of
  `/api/v1/provisioning/*` endpoints on a freshly started instance with no provisioning file
  loaded. The previous Milestone 5 became Milestone 6 and the previous Milestone 6 became
  Milestone 7. Progress, Surprises & Discoveries, Decision Log, Concrete Steps, Validation and
  Acceptance, and Interfaces and Dependencies were updated to match. `grafana/grafana.ini` is
  now listed as a modified file. The motivation is that "verify against Grafana" is only
  meaningful if Grafana's alerting subsystem is actually installed and reachable; this revision
  makes that an explicit, testable precondition.

- 2026-05-07: Implemented the plan end to end. Added alerting Dhall types, defaults, package
  exports, an expression-rule example, Justfile alerting recipes, Grafana alerting provisioning
  directory, explicit `[unified_alerting]` configuration, README documentation, and a masterplan
  follow-up entry. Live Grafana validation discovered that Grafana 12.4.2 expects notification
  policy `object_matchers` as three-item tuples and requires the root policy receiver to reference
  an existing contact point. The implementation was revised accordingly and validated through the
  provisioning API.
