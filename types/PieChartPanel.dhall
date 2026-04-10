let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < piechart >

let PieType = < pie | donut >

let LegendDisplayMode = < list | table | hidden >

let LegendPlacement = < bottom | right >

let TooltipMode = < single | multi | none >

let TooltipSort = < none | asc | desc >

let DisplayLabel = < name | value | percent >

let CalcMode =
      < lastNotNull
      | last
      | firstNotNull
      | first
      | min
      | max
      | mean
      | total
      | count
      | range
      | delta
      | step
      | diff
      | logmin
      | allIsZero
      | allIsNull
      | changeCount
      | distinctCount
      >

let PieChartOptions =
      { pieType : PieType
      , reduceOptions : { calcs : List CalcMode, fields : Text, values : Bool }
      , legend :
          { calcs : List CalcMode
          , displayMode : LegendDisplayMode
          , placement : LegendPlacement
          , showLegend : Bool
          , values : List CalcMode
          , width : Optional Natural
          }
      , tooltip :
          { mode : TooltipMode, sort : TooltipSort, maxHeight : Natural }
      , displayLabels : List DisplayLabel
      }

let PieChartFieldConfig = {}

let PieChartPanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : PieChartOptions
            , fieldConfig : ModernFieldConfig PieChartFieldConfig
            }

in  { Type = PieChartPanel
    , PanelType
    , PieType
    , LegendDisplayMode
    , LegendPlacement
    , TooltipMode
    , TooltipSort
    , DisplayLabel
    , CalcMode
    , PieChartOptions
    , PieChartFieldConfig
    }
