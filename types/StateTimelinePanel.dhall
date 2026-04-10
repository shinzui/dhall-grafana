let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < state-timeline >

let AlignValue = < left | center >

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

let StateTimelineOptions =
      { mergeValues : Bool
      , alignValue : AlignValue
      , rowHeight : Double
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

let StateTimelineFieldConfig = { lineWidth : Natural, fillOpacity : Natural }

let StateTimelinePanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : StateTimelineOptions
            , fieldConfig : ModernFieldConfig StateTimelineFieldConfig
            }

in  { Type = StateTimelinePanel
    , PanelType
    , AlignValue
    , LegendDisplayMode
    , LegendPlacement
    , TooltipMode
    , TooltipSort
    , CalcMode
    , StateTimelineOptions
    , StateTimelineFieldConfig
    }
