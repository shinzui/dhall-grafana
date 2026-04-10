let DatasourceRef = ../types/DatasourceRef.dhall

let RawQueryTarget = ../types/RawQueryTarget.dhall

in    { hide = False
      , queryType = RawQueryTarget.RawQueryType.raw
      , rawQuery = ""
      , refId = ""
      , datasource = None DatasourceRef
      }
    : RawQueryTarget.Type
