let TrendPanel = ../types/TrendPanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = TrendPanel.PanelType.trend
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
      { legend =
        { calcs = [] : List TrendPanel.CalcMode
        , displayMode = TrendPanel.LegendDisplayMode.list
        , placement = TrendPanel.LegendPlacement.bottom
        , showLegend = True
        , width = None Natural
        }
      , tooltip =
        { mode = TrendPanel.TooltipMode.single
        , sort = TrendPanel.TooltipSort.none
        , maxHeight = 600
        }
      , xField = None Text
      }
    , fieldConfig =
      { defaults =
        { color =
          { fixedColor = None Text
          , mode = FieldConfig.ColorMode.palette-classic
          }
        , custom =
          { drawStyle = TrendPanel.DrawStyle.line
          , lineInterpolation = TrendPanel.LineInterpolation.linear
          , lineWidth = 1
          , fillOpacity = 0
          , gradientMode = TrendPanel.GradientMode.none
          , showPoints = TrendPanel.ShowPoints.auto
          , pointSize = 5
          , stacking = { mode = TrendPanel.StackingMode.none, group = "A" }
          , barAlignment = +0
          , spanNulls = False
          , axisCenteredZero = False
          , axisColorMode = TrendPanel.AxisColorMode.text
          , axisLabel = ""
          , axisPlacement = TrendPanel.AxisPlacement.auto
          , scaleDistribution =
            { type = TrendPanel.ScaleType.linear, log = None Natural }
          , thresholdsStyle.mode = TrendPanel.ThresholdsStyleMode.off
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
