let Schema =
      https://raw.githubusercontent.com/shinzui/mori-schema/1f70781427426c09673d46f8e6733b7e7d0abedc/package.dhall
        sha256:3b79aae9216456678300441ca8616b64a4b4fa520a1286dfcc418f60899d5d4a

in  Schema.Project::{
    , project = Schema.ProjectIdentity::{
      , name = "dhall-grafana"
      , namespace = "shinzui"
      , type = Schema.PackageType.Library
      , language = Schema.Language.Dhall
      , lifecycle = Schema.Lifecycle.Active
      , description = Some
          "Type-safe Grafana dashboards-as-code with Dhall, modernized for Grafana v11"
      , domains = [ "Observability" ]
      , owners = [ "shinzui" ]
      }
    , repos =
      [ Schema.Repo::{
        , name = "dhall-grafana"
        , github = Some "shinzui/dhall-grafana"
        }
      ]
    , packages =
      [ Schema.Package::{
        , name = "dhall-grafana"
        , type = Schema.PackageType.Library
        , language = Schema.Language.Dhall
        , description = Some
            "Dhall types and defaults for Grafana v11 dashboards, panels, datasources, and unified alerting"
        }
      ]
    }
