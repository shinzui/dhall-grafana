let HistogramPanel = ../types/HistogramPanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = HistogramPanel.PanelType.histogram
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
      { bucketCount = None Natural
      , bucketSize = None Double
      , combine = False
      , fillOpacity = 80
      , gradientMode = HistogramPanel.GradientMode.none
      , stacking = HistogramPanel.StackingMode.none
      , legend =
        { calcs = [] : List HistogramPanel.CalcMode
        , displayMode = HistogramPanel.LegendDisplayMode.list
        , placement = HistogramPanel.LegendPlacement.bottom
        , showLegend = True
        , width = None Natural
        }
      , tooltip =
        { mode = HistogramPanel.TooltipMode.single
        , sort = HistogramPanel.TooltipSort.none
        , maxHeight = 600
        }
      }
    , fieldConfig =
      { defaults =
        { color =
          { fixedColor = None Text
          , mode = FieldConfig.ColorMode.palette-classic
          }
        , custom =
          { lineWidth = 1
          , fillOpacity = 80
          , gradientMode = HistogramPanel.GradientMode.none
          , axisCenteredZero = False
          }
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
