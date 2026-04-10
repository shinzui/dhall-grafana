let DatasourceRef = ./DatasourceRef.dhall

let FormatType = < table | time_series | heatmap >

let EditorMode = < code | builder >

let PrometheusTarget =
      { refId : Text
      , expr : Text
      , intervalFactor : Natural
      , format : FormatType
      , legendFormat : Text
      , interval : Optional Text
      , instant : Bool
      , range : Bool
      , editorMode : EditorMode
      , datasource : Optional DatasourceRef
      , scenarioId : Optional (./TestDataDBTarget.dhall).ScenarioId
      }

in  { Type = PrometheusTarget, FormatType, EditorMode }
