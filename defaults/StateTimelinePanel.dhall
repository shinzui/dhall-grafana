let StateTimelinePanel = ../types/StateTimelinePanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let Link = ../types/Link.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = StateTimelinePanel.PanelType.state-timeline
    , id = 0
    , links = [] : List Link.Types
    , transparent = False
    , repeat = None Text
    , repeatDirection = None ../types/Direction.dhall
    , maxPerRow = None Natural
    , alert = None (../types/Alert.dhall).Type
    , transformations = [] : List (../types/Transformations.dhall).Types
    , datasource = None { type : Text, uid : Text }
    , targets = [] : List MetricTargets
    , options =
      { mergeValues = True
      , alignValue = StateTimelinePanel.AlignValue.left
      , rowHeight = 0.9
      , legend =
        { calcs = [] : List StateTimelinePanel.CalcMode
        , displayMode = StateTimelinePanel.LegendDisplayMode.list
        , placement = StateTimelinePanel.LegendPlacement.bottom
        , showLegend = True
        , width = None Natural
        }
      , tooltip =
        { mode = StateTimelinePanel.TooltipMode.single
        , sort = StateTimelinePanel.TooltipSort.none
        , maxHeight = 600
        }
      }
    , fieldConfig =
      { defaults =
        { color =
          { fixedColor = None Text, mode = FieldConfig.ColorMode.thresholds }
        , custom = { lineWidth = 0, fillOpacity = 70 }
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
            [ { color = "green", value = None Double }
            , { color = "red", value = Some 80.0 }
            ]
          }
        }
      , overrides = [] : List FieldConfig.Override
      }
    }
