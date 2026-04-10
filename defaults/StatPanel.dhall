let StatPanel = ../types/StatPanel.dhall

let MetricTargets = ../types/MetricTargets.dhall

let Link = ../types/Link.dhall

let StatPanel =
      { type = StatPanel.PanelType.stat
      , id = 0
      , links = [] : List Link.Type
      , repeat = None Text
      , repeatDirection = None ../types/Direction.dhall
      , maxPerRow = None Natural
      , transparent = False
      , timeFrom = None Text
      , timeShift = None Text
      , hideTimeOverride = False
      , options = ./StatPanelOptions.dhall
      , datasource = None ../types/DatasourceRef.dhall
      , targets = [] : List MetricTargets
      , maxDataPoints = 100
      , transformations = [] : List (../types/Transformations.dhall).Types
      , fieldConfig = None (../types/FieldConfig.dhall).Type
      }

in  { StatPanel }
