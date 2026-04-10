let Grafana = ../package.dhall

let ScenarioId = Grafana.ScenarioId

let datasourceName = "Datasource"

let panels =
      [ Grafana.Panels.mkStatPanel
          Grafana.StatPanel::{
          , title = "Stat panel"
          , gridPos = { x = 0, y = 0, w = 24, h = 3 }
          , targets =
            [ Grafana.MetricsTargets.TestDataDBTarget
                Grafana.TestDataDBTarget::{ refId = "A" }
            ]
          }
      , Grafana.Panels.mkRow
          Grafana.Row::{
          , title = "This is the \$Custom row"
          , gridPos = { x = 0, y = 4, w = 24, h = 1 }
          , repeat = Some "Custom"
          }
      , Grafana.Panels.mkTextPanel
          Grafana.TextPanel::{
          , title = "Markdown panel"
          , gridPos = { x = 0, y = 5, w = 12, h = 6 }
          , options =
            { content =
                ''
                # foo

                $Custom
                ''
            , mode = Grafana.TextPanels.Mode.markdown
            }
          }
      , Grafana.Panels.mkTextPanel
          Grafana.TextPanel::{
          , title = "Html panel"
          , gridPos = { x = 12, y = 5, w = 12, h = 6 }
          , options =
            { content =
                ''
                <h1>bar</h1>
                <br>
                $Custom
                ''
            , mode = Grafana.TextPanels.Mode.html
            }
          }
      , Grafana.Panels.mkTimeSeriesPanel
          Grafana.TimeSeriesPanel::{
          , title = "Temperature"
          , gridPos = { x = 0, y = 12, w = 24, h = 6 }
          , targets =
            [ Grafana.MetricsTargets.TestDataDBTarget
                Grafana.TestDataDBTarget::{ refId = "A" }
            ]
          }
      ]

let templateVariables =
      [ Grafana.TemplatingVariableUtils.mkInterval
          "Interval"
          [ "5s", "10s", "15s", "20s", "25s" ]
          False
      , Grafana.TemplatingVariableUtils.mkDatasource
          datasourceName
          "testdata"
          ""
          False
      , Grafana.TemplatingVariableUtils.mkCustom
          "Custom"
          [ "1st", "2nd", "3rd" ]
          False
      , Grafana.TemplatingVariableUtils.mkConstant "Constant" "foobarbaz" False
      , Grafana.TemplatingVariableUtils.mkTextbox
          "Textbox"
          ''
          some textbox value
          ''
          False
      , Grafana.TemplatingVariableUtils.mkAdHoc
          "Adhoc"
          { type = "testdata", uid = "testdata" }
          False
      ]

let links =
      [ Grafana.LinkDashboards::{
        , tags = [ "prometheus" ]
        , title = "Dashboards"
        }
      , Grafana.LinkExternal::{
        , title = "Links"
        , url = Some "https://learnxinyminutes.com/docs/dhall/"
        , tooltip = "Learn Dhall"
        }
      ]

let dashboard
    : Grafana.Dashboard.Type
    = Grafana.Dashboard::{
      , title = "dhall-grafana sample"
      , uid = Some "dhall-grafana-sample"
      , panels = Grafana.Utils.generateIds panels
      , editable = True
      , templating.list = templateVariables
      , links
      }

in  dashboard
