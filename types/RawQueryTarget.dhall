let DatasourceRef = ./DatasourceRef.dhall

let RawQueryType
    : Type
    = < raw >

let RawQueryTarget
    : Type
    = { hide : Bool
      , queryType : RawQueryType
      , rawQuery : Text
      , refId : Text
      , datasource : Optional DatasourceRef
      }

in  { Type = RawQueryTarget, RawQueryType }
