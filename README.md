# dhall-grafana

Type-safe [Grafana](https://grafana.com/) dashboards-as-code with [Dhall](https://dhall-lang.org/).

> This is a fork of [weeezes/dhall-grafana](https://github.com/weeezes/dhall-grafana), originally created by Vesa Hagström. The original project targeted Grafana 6–7 (schema version 17) and is no longer actively maintained. This fork is being modernized to support **Grafana v11** (schema version 39) with updated types, modern panel support, and a reproducible Nix-based development environment.

## What's changing

The modernization is tracked in four sequential execution plans:

| Phase | Description | Status |
|-------|-------------|--------|
| [EP-1](docs/plans/1-nix-flake-process-compose.md) | Nix flake, process-compose, dev tooling | In progress |
| [EP-2](docs/plans/2-modernize-core-types.md) | Dashboard schema v39, modern FieldConfig | Not started |
| [EP-3](docs/plans/3-modern-panel-types.md) | TimeSeries, BarChart, PieChart, Histogram, StateTimeline, StatusHistory | Not started |
| [EP-4](docs/plans/4-modernize-datasource-targets.md) | Modernized Prometheus, new Loki target, datasource UIDs | Not started |

See the [master plan](docs/masterplans/1-revamp-dhall-grafana.md) for full details.

## Current capabilities

**Panel types:** GraphPanel, StatPanel, SinglestatPanel, TextPanel, TablePanel, Row

**Data source targets:** Prometheus, InfluxDB, TestDataDB, RawQuery

**Dashboard features:** Templating variables, links, legends, transformations, field config with thresholds and color modes, legacy per-panel alerts

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled
- [direnv](https://direnv.net/) (recommended)

The dev shell provides all required tools: `dhall-json`, `process-compose`, `just`, `grafana`, `prometheus`, `check-jsonschema`, and more.

## Getting started

### Enter the dev environment

```sh
# With direnv (recommended)
direnv allow

# Or manually
nix develop
```

### Start local services

```sh
process-compose up
```

This starts Grafana (port 3000) and Prometheus (port 9090). Dashboards compiled to `out/` are auto-provisioned into Grafana with a 5-second reload interval.

### Build example dashboards

```sh
dhall-to-json --file examples/all_dashboard.dhall > out/all_dashboard.json
```

Open [http://localhost:3000](http://localhost:3000) to see your dashboards. Anonymous auth is enabled with Admin access for local development.

## Usage

Import the package and use record completion (`::`) to build dashboards with sensible defaults:

```dhall
let Grafana = ./package.dhall

in  Grafana.Dashboard::{
    , title = "My Dashboard"
    , panels =
        Grafana.Utils.generateIds
          [ Grafana.Panels.mkGraphPanel
              Grafana.GraphPanel::{
              , title = "Request Rate"
              , gridPos = { x = 0, y = 0, w = 12, h = 8 }
              , targets =
                [ Grafana.MetricsTargets.PrometheusTarget
                    Grafana.PrometheusTarget::{
                    , expr = "rate(http_requests_total[5m])"
                    }
                ]
              }
          , Grafana.Panels.mkStatPanel
              Grafana.StatPanel::{
              , title = "Total Requests"
              , gridPos = { x = 12, y = 0, w = 6, h = 4 }
              , targets =
                [ Grafana.MetricsTargets.PrometheusTarget
                    Grafana.PrometheusTarget::{
                    , expr = "http_requests_total"
                    }
                ]
              }
          ]
    }
```

Compile to JSON and import into Grafana:

```sh
dhall-to-json --file my_dashboard.dhall > out/my_dashboard.json
```

### Exploring types and defaults

Every type is defined in [`types/`](./types/) and has a corresponding default in [`defaults/`](./defaults/). The full API is exported from [`package.dhall`](./package.dhall). Use record completion (`::`) to override only the fields you need.

## Examples

| Example | Description |
|---------|-------------|
| [all_dashboard.dhall](examples/all_dashboard.dhall) | Comprehensive showcase of all panel types, templating variables, and links |
| [consul_exporter.dhall](examples/consul_exporter.dhall) | Real-world Consul monitoring with Prometheus targets and data transformations |
| [hass_indoor.dhall](examples/hass_indoor.dhall) | Home Assistant indoor environment dashboard |
| [influxdb.dhall](examples/influxdb.dhall) | InfluxDB query example (compile-only, no running InfluxDB needed) |

## Project structure

```
├── package.dhall              # Main entry point — exports all types and defaults
├── types/                     # Dhall type definitions
├── defaults/                  # Default values for each type
├── examples/                  # Example dashboards
├── schemas/                   # Specialized schema types (Lucene)
├── grafana/                   # Grafana provisioning configs
│   ├── grafana.ini
│   └── provisioning/
│       ├── datasources/       # TestData, Prometheus
│       └── dashboards/        # Auto-load from out/
├── flake.nix                  # Nix flake with devShell
├── process-compose.yaml       # Grafana + Prometheus orchestration
├── treefmt.nix                # Code formatting (Dhall, Nix)
├── out/                       # Compiled dashboard JSON (gitignored)
└── docs/
    ├── masterplans/           # High-level initiative planning
    └── plans/                 # Execution plans (EP-1 through EP-4)
```

## Acknowledgments

This project is a fork of [weeezes/dhall-grafana](https://github.com/weeezes/dhall-grafana) by Vesa Hagström. The original library established the patterns for modeling Grafana dashboards in Dhall that this fork continues to build on.
