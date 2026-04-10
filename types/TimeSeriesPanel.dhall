let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < timeseries >

let DrawStyle = < line | bars | points >

let LineInterpolation = < linear | smooth | stepBefore | stepAfter >

let ShowPoints = < auto | always | never >

let GradientMode = < none | opacity | hue | scheme >

let StackingMode = < none | normal | percent >

let AxisColorMode = < text | series >

let AxisPlacement = < auto | left | right | hidden >

let ScaleType = < linear | log >

let ThresholdsStyleMode = < off | line | area | `line+area` >

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

let TimeSeriesOptions =
      { legend :
          { calcs : List CalcMode
          , displayMode : LegendDisplayMode
          , placement : LegendPlacement
          , showLegend : Bool
          , width : Optional Natural
          }
      , tooltip :
          { mode : TooltipMode, sort : TooltipSort, maxHeight : Natural }
      }

let TimeSeriesFieldConfig =
      { drawStyle : DrawStyle
      , lineInterpolation : LineInterpolation
      , lineWidth : Natural
      , fillOpacity : Natural
      , gradientMode : GradientMode
      , showPoints : ShowPoints
      , pointSize : Natural
      , stacking : { mode : StackingMode, group : Text }
      , barAlignment : Integer
      , spanNulls : Bool
      , axisCenteredZero : Bool
      , axisColorMode : AxisColorMode
      , axisLabel : Text
      , axisPlacement : AxisPlacement
      , scaleDistribution : { type : ScaleType, log : Optional Natural }
      , thresholdsStyle : { mode : ThresholdsStyleMode }
      }

let TimeSeriesPanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : TimeSeriesOptions
            , fieldConfig : ModernFieldConfig TimeSeriesFieldConfig
            }

in  { Type = TimeSeriesPanel
    , PanelType
    , DrawStyle
    , LineInterpolation
    , ShowPoints
    , GradientMode
    , StackingMode
    , AxisColorMode
    , AxisPlacement
    , ScaleType
    , ThresholdsStyleMode
    , LegendDisplayMode
    , LegendPlacement
    , TooltipMode
    , TooltipSort
    , CalcMode
    , TimeSeriesOptions
    , TimeSeriesFieldConfig
    }
