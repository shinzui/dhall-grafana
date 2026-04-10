let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < histogram >

let GradientMode = < none | opacity | hue | scheme >

let StackingMode = < none | normal | percent >

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

let HistogramOptions =
      { bucketCount : Optional Natural
      , bucketSize : Optional Double
      , combine : Bool
      , fillOpacity : Natural
      , gradientMode : GradientMode
      , stacking : StackingMode
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

let HistogramFieldConfig =
      { lineWidth : Natural
      , fillOpacity : Natural
      , gradientMode : GradientMode
      , axisCenteredZero : Bool
      }

let HistogramPanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : HistogramOptions
            , fieldConfig : ModernFieldConfig HistogramFieldConfig
            }

in  { Type = HistogramPanel
    , PanelType
    , GradientMode
    , StackingMode
    , LegendDisplayMode
    , LegendPlacement
    , TooltipMode
    , TooltipSort
    , CalcMode
    , HistogramOptions
    , HistogramFieldConfig
    }
