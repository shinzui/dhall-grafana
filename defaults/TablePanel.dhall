let TablePanel = ../types/TablePanel.dhall

let MetricTargets = ../types/MetricTargets.dhall

in  { type = TablePanel.PanelType.table
    , id = 0
    , links = [] : List (../types/Link.dhall).Type
    , repeat = None Text
    , repeatDirection = None ../types/Direction.dhall
    , maxPerRow = None Natural
    , datasource = None ../types/DatasourceRef.dhall
    , targets = [] : List MetricTargets
    , options = {=}
    , timeFrom = None Text
    , timeShift = None Text
    , hideTimeOverride = False
    , transparent = False
    , transformations = [] : List (../types/Transformations.dhall).Types
    , fieldConfig = None (../types/FieldConfig.dhall).Type
    }
