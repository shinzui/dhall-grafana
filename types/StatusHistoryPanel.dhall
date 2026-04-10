let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < status-history >

let ShowValue = < auto | always | never >

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

let StatusHistoryOptions =
      { showValue : ShowValue
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

let StatusHistoryFieldConfig = { lineWidth : Natural, fillOpacity : Natural }

let StatusHistoryPanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : StatusHistoryOptions
            , fieldConfig : ModernFieldConfig StatusHistoryFieldConfig
            }

in  { Type = StatusHistoryPanel
    , PanelType
    , ShowValue
    , LegendDisplayMode
    , LegendPlacement
    , TooltipMode
    , TooltipSort
    , CalcMode
    , StatusHistoryOptions
    , StatusHistoryFieldConfig
    }
