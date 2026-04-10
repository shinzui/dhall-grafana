let TimeZoneOption = < utc | browser >

let Dashboard =
      { id : Natural
      , uid : Optional Text
      , title : Text
      , tags : List Text
      , timezone : Optional TimeZoneOption
      , editable : Bool
      , graphTooltip : Natural
      , panels : List (./Panels.dhall).Panels
      , time : ./Time.dhall
      , timepicker : (./TimePicker.dhall).Type
      , templating : { list : List (./TemplatingVariable.dhall).Types }
      , annotations : { list : List ./Annotation.dhall }
      , refresh : Text
      , schemaVersion : Natural
      , version : Natural
      , links : List (./Link.dhall).Type
      , fiscalYearStartMonth : Natural
      , liveNow : Bool
      , weekStart : Text
      }

in  { Type = Dashboard, Timezone = TimeZoneOption }
