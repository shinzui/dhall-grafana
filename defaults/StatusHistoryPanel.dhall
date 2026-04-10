let StatusHistoryPanel = ../types/StatusHistoryPanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = StatusHistoryPanel.PanelType.status-history
    , id = 0
    , links = [] : List (../types/Link.dhall).Type
    , transparent = False
    , repeat = None Text
    , repeatDirection = None ../types/Direction.dhall
    , maxPerRow = None Natural
    , transformations = [] : List (../types/Transformations.dhall).Types
    , datasource = None { type : Text, uid : Text }
    , targets = [] : List MetricTargets
    , options =
      { showValue = StatusHistoryPanel.ShowValue.auto
      , rowHeight = 0.9
      , legend =
        { calcs = [] : List StatusHistoryPanel.CalcMode
        , displayMode = StatusHistoryPanel.LegendDisplayMode.list
        , placement = StatusHistoryPanel.LegendPlacement.bottom
        , showLegend = True
        , width = None Natural
        }
      , tooltip =
        { mode = StatusHistoryPanel.TooltipMode.single
        , sort = StatusHistoryPanel.TooltipSort.none
        , maxHeight = 600
        }
      }
    , fieldConfig =
      { defaults =
        { color =
          { fixedColor = None Text, mode = FieldConfig.ColorMode.thresholds }
        , custom = { lineWidth = 1, fillOpacity = 70 }
        , unit = None Text
        , decimals = None Natural
        , displayName = None Text
        , min = None Double
        , max = None Double
        , noValue = None Text
        , links = [] : List DataLink
        , mappings = [] : List ValueMapping
        , thresholds =
          { mode = FieldConfig.ThresholdMode.absolute
          , steps =
            [ { color = "green", value = 0.0 }
            , { color = "red", value = 80.0 }
            ]
          }
        }
      , overrides = [] : List FieldConfig.Override
      }
    }
