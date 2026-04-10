let Grafana = ../package.dhall

let ScenarioId = Grafana.ScenarioId

let datasourceName = "TestData"

let datasource = Some { type = "testdata", uid = "testdata" }

let panels =
      [ Grafana.Panels.mkTimeSeriesPanel
          (   Grafana.TimeSeriesPanel.default
            ⫽ { title = "TimeSeries: CPU Usage"
              , gridPos = { x = 0, y = 0, w = 12, h = 8 }
              , datasource
              , targets =
                [ Grafana.MetricsTargets.TestDataDBTarget
                    { refId = "A", scenarioId = ScenarioId.random_walk }
                ]
              }
          )
      , Grafana.Panels.mkBarChartPanel
          (   Grafana.BarChartPanel.default
            ⫽ { title = "BarChart: Request Counts"
              , gridPos = { x = 12, y = 0, w = 12, h = 8 }
              , datasource
              , targets =
                [ Grafana.MetricsTargets.TestDataDBTarget
                    { refId = "A", scenarioId = ScenarioId.random_walk_table }
                ]
              }
          )
      , Grafana.Panels.mkPieChartPanel
          (   Grafana.PieChartPanel.default
            ⫽ { title = "PieChart: Distribution"
              , gridPos = { x = 0, y = 8, w = 12, h = 8 }
              , datasource
              , targets =
                [ Grafana.MetricsTargets.TestDataDBTarget
                    { refId = "A", scenarioId = ScenarioId.random_walk_table }
                ]
              }
          )
      , Grafana.Panels.mkHistogramPanel
          (   Grafana.HistogramPanel.default
            ⫽ { title = "Histogram: Latency Distribution"
              , gridPos = { x = 12, y = 8, w = 12, h = 8 }
              , datasource
              , targets =
                [ Grafana.MetricsTargets.TestDataDBTarget
                    { refId = "A", scenarioId = ScenarioId.random_walk }
                ]
              }
          )
      , Grafana.Panels.mkStateTimelinePanel
          (   Grafana.StateTimelinePanel.default
            ⫽ { title = "StateTimeline: Service States"
              , gridPos = { x = 0, y = 16, w = 12, h = 8 }
              , datasource
              , targets =
                [ Grafana.MetricsTargets.TestDataDBTarget
                    { refId = "A", scenarioId = ScenarioId.random_walk }
                ]
              }
          )
      , Grafana.Panels.mkStatusHistoryPanel
          (   Grafana.StatusHistoryPanel.default
            ⫽ { title = "StatusHistory: Health Grid"
              , gridPos = { x = 12, y = 16, w = 12, h = 8 }
              , datasource
              , targets =
                [ Grafana.MetricsTargets.TestDataDBTarget
                    { refId = "A", scenarioId = ScenarioId.random_walk }
                ]
              }
          )
      ]

let dashboard
    : Grafana.Dashboard.Type
    = Grafana.Dashboard::{
      , title = "Modern Panel Types"
      , uid = Some "dhall-grafana-modern-panels"
      , panels = Grafana.Utils.generateIds panels
      , editable = True
      }

in  dashboard
