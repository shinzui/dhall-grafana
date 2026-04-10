let BarChartPanel = ../types/BarChartPanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let Link = ../types/Link.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = BarChartPanel.PanelType.barchart
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
      { orientation = BarChartPanel.Orientation.vertical
      , barWidth = 0.97
      , barRadius = 0.0
      , groupWidth = 0.7
      , stacking = BarChartPanel.StackingMode.none
      , showValue = BarChartPanel.ShowValue.auto
      , xTickLabelRotation = +0
      , xTickLabelSpacing = 0
      , colorByField = None Text
      , legend =
        { calcs = [] : List BarChartPanel.CalcMode
        , displayMode = BarChartPanel.LegendDisplayMode.list
        , placement = BarChartPanel.LegendPlacement.bottom
        , showLegend = True
        , width = None Natural
        }
      , tooltip =
        { mode = BarChartPanel.TooltipMode.single
        , sort = BarChartPanel.TooltipSort.none
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
          , gradientMode = BarChartPanel.GradientMode.none
          , axisCenteredZero = False
          , axisColorMode = BarChartPanel.AxisColorMode.text
          , axisLabel = ""
          , axisPlacement = BarChartPanel.AxisPlacement.auto
          , scaleDistribution =
            { type = BarChartPanel.ScaleType.linear, log = None Natural }
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
