let DatasourceRef = ./DatasourceRef.dhall

let EditorMode = < code | builder >

let QueryType = < range | instant >

let LokiTarget =
      { datasource : Optional DatasourceRef
      , editorMode : EditorMode
      , expr : Text
      , queryType : QueryType
      , refId : Text
      , legendFormat : Optional Text
      , maxLines : Natural
      }

in  { Type = LokiTarget, EditorMode, QueryType }
