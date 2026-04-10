let TimeSeriesPanel = ../types/TimeSeriesPanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let Link = ../types/Link.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = TimeSeriesPanel.PanelType.timeseries
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
      { legend =
        { calcs = [] : List TimeSeriesPanel.CalcMode
        , displayMode = TimeSeriesPanel.LegendDisplayMode.list
        , placement = TimeSeriesPanel.LegendPlacement.bottom
        , showLegend = True
        , width = None Natural
        }
      , tooltip =
        { mode = TimeSeriesPanel.TooltipMode.single
        , sort = TimeSeriesPanel.TooltipSort.none
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
          { drawStyle = TimeSeriesPanel.DrawStyle.line
          , lineInterpolation = TimeSeriesPanel.LineInterpolation.linear
          , lineWidth = 1
          , fillOpacity = 0
          , gradientMode = TimeSeriesPanel.GradientMode.none
          , showPoints = TimeSeriesPanel.ShowPoints.auto
          , pointSize = 5
          , stacking = { mode = TimeSeriesPanel.StackingMode.none, group = "A" }
          , barAlignment = +0
          , spanNulls = False
          , axisCenteredZero = False
          , axisColorMode = TimeSeriesPanel.AxisColorMode.text
          , axisLabel = ""
          , axisPlacement = TimeSeriesPanel.AxisPlacement.auto
          , scaleDistribution =
            { type = TimeSeriesPanel.ScaleType.linear, log = None Natural }
          , thresholdsStyle.mode = TimeSeriesPanel.ThresholdsStyleMode.off
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
            [ { color = "green", value = None Double }
            , { color = "red", value = Some 80.0 }
            ]
          }
        }
      , overrides = [] : List FieldConfig.Override
      }
    }
