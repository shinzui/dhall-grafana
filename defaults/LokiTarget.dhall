let DatasourceRef = ../types/DatasourceRef.dhall

let LokiTarget = ../types/LokiTarget.dhall

in  { datasource = None DatasourceRef
    , editorMode = LokiTarget.EditorMode.code
    , expr = ""
    , queryType = LokiTarget.QueryType.range
    , refId = "A"
    , legendFormat = None Text
    , maxLines = 1000
    }
