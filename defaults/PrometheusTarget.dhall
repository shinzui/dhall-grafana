let PrometheusTarget = ../types/PrometheusTarget.dhall

let DatasourceRef = ../types/DatasourceRef.dhall

let ScenarioId = (../types/TestDataDBTarget.dhall).ScenarioId

in  { intervalFactor = 1
    , format = PrometheusTarget.FormatType.time_series
    , legendFormat = "__auto"
    , interval = None Text
    , instant = False
    , range = True
    , editorMode = PrometheusTarget.EditorMode.code
    , datasource = None DatasourceRef
    , scenarioId = None ScenarioId
    }
