let DatasourceRef = ../types/DatasourceRef.dhall

in  { orderByTime = "DESC"
    , resultFormat = "time_series"
    , policy = "default"
    , datasource = None DatasourceRef
    , query = None Text
    , language = None Text
    }
