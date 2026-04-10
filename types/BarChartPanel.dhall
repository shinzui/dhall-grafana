let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < barchart >

let Orientation = < horizontal | vertical >

let ShowValue = < auto | always | never >

let StackingMode = < none | normal | percent >

let GradientMode = < none | opacity | hue | scheme >

let AxisColorMode = < text | series >

let AxisPlacement = < auto | left | right | hidden >

let ScaleType = < linear | log >

let LegendDisplayMode = < list | table | hidden >

let LegendPlacement = < bottom | right >

let TooltipMode = < single | multi | none >

let TooltipSort = < none | asc | desc >

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

let BarChartOptions =
      { orientation : Orientation
      , barWidth : Double
      , barRadius : Double
      , groupWidth : Double
      , stacking : StackingMode
      , showValue : ShowValue
      , xTickLabelRotation : Integer
      , xTickLabelSpacing : Natural
      , colorByField : Optional Text
      , legend :
          { calcs : List CalcMode
          , displayMode : LegendDisplayMode
          , placement : LegendPlacement
          , showLegend : Bool
          , width : Optional Natural
          }
      , tooltip :
          { mode : TooltipMode, sort : TooltipSort, maxHeight : Natural }
      }

let BarChartFieldConfig =
      { lineWidth : Natural
      , fillOpacity : Natural
      , gradientMode : GradientMode
      , axisCenteredZero : Bool
      , axisColorMode : AxisColorMode
      , axisLabel : Text
      , axisPlacement : AxisPlacement
      , scaleDistribution : { type : ScaleType, log : Optional Natural }
      }

let BarChartPanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : BarChartOptions
            , fieldConfig : ModernFieldConfig BarChartFieldConfig
            }

in  { Type = BarChartPanel
    , PanelType
    , Orientation
    , ShowValue
    , StackingMode
    , GradientMode
    , AxisColorMode
    , AxisPlacement
    , ScaleType
    , LegendDisplayMode
    , LegendPlacement
    , TooltipMode
    , TooltipSort
    , CalcMode
    , BarChartOptions
    , BarChartFieldConfig
    }
