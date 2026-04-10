let PieChartPanel = ../types/PieChartPanel.dhall

let FieldConfig = ../types/FieldConfig.dhall

let MetricTargets = ../types/MetricTargets.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

in  { type = PieChartPanel.PanelType.piechart
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
      { pieType = PieChartPanel.PieType.pie
      , reduceOptions =
        { calcs = [ PieChartPanel.CalcMode.lastNotNull ]
        , fields = ""
        , values = False
        }
      , legend =
        { calcs = [] : List PieChartPanel.CalcMode
        , displayMode = PieChartPanel.LegendDisplayMode.list
        , placement = PieChartPanel.LegendPlacement.bottom
        , showLegend = True
        , values = [] : List PieChartPanel.CalcMode
        , width = None Natural
        }
      , tooltip =
        { mode = PieChartPanel.TooltipMode.single
        , sort = PieChartPanel.TooltipSort.none
        , maxHeight = 600
        }
      , displayLabels = [] : List PieChartPanel.DisplayLabel
      }
    , fieldConfig =
      { defaults =
        { color =
          { fixedColor = None Text
          , mode = FieldConfig.ColorMode.palette-classic
          }
        , custom = {=}
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
