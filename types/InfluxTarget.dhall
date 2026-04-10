let DatasourceRef = ./DatasourceRef.dhall

let InfluxGroup = { params : List Text, type : Text }

let InfluxTag = { key : Text, operator : Text, value : Text }

let InfluxTarget =
      { groupBy : List InfluxGroup
      , select : List (List InfluxGroup)
      , measurement : Text
      , orderByTime : Text
      , policy : Text
      , resultFormat : Text
      , refId : Text
      , tags : List InfluxTag
      , alias : Text
      , datasource : Optional DatasourceRef
      , query : Optional Text
      , language : Optional Text
      }

in  { Type = InfluxTarget, InfluxGroup, InfluxTag }
