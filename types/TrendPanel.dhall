{-|
The Trend panel renders a series against a *sequential numeric* x-axis instead of
time — function graphs, rpm/torque curves, and cumulative distribution functions.

It is the time series panel with the time axis swapped for an arbitrary numeric
field, so it reuses `TimeSeriesPanel`'s graph-style vocabulary verbatim
(`DrawStyle`, `LineInterpolation`, `ScaleType`, legend and tooltip modes) and adds
a single option, `xField`.

Grafana requires the x-field to hold **ascending numeric** values; a string field
(such as a Prometheus `le` label) or an unsorted one makes the panel render an
error instead of a chart. Convert and sort it with the `ConvertFieldType` and
`SortBy` transformations first.
-}
let TimeSeries = ./TimeSeriesPanel.dhall

let MetricTargets = ./MetricTargets.dhall

let ModernFieldConfig = ./ModernFieldConfig.dhall

let PanelType = < trend >

let TrendOptions =
      { legend :
          { calcs : List TimeSeries.CalcMode
          , displayMode : TimeSeries.LegendDisplayMode
          , placement : TimeSeries.LegendPlacement
          , showLegend : Bool
          , width : Optional Natural
          }
      , tooltip :
          { mode : TimeSeries.TooltipMode
          , sort : TimeSeries.TooltipSort
          , maxHeight : Natural
          }
      , xField : Optional Text
      }

let TrendPanel =
          ./ModernBasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional { type : Text, uid : Text }
            , targets : List MetricTargets
            , options : TrendOptions
            , fieldConfig : ModernFieldConfig TimeSeries.TimeSeriesFieldConfig
            }

in  { Type = TrendPanel
    , PanelType
    , TrendOptions
    , TrendFieldConfig = TimeSeries.TimeSeriesFieldConfig
    , DrawStyle = TimeSeries.DrawStyle
    , LineInterpolation = TimeSeries.LineInterpolation
    , ShowPoints = TimeSeries.ShowPoints
    , GradientMode = TimeSeries.GradientMode
    , StackingMode = TimeSeries.StackingMode
    , AxisColorMode = TimeSeries.AxisColorMode
    , AxisPlacement = TimeSeries.AxisPlacement
    , ScaleType = TimeSeries.ScaleType
    , ThresholdsStyleMode = TimeSeries.ThresholdsStyleMode
    , LegendDisplayMode = TimeSeries.LegendDisplayMode
    , LegendPlacement = TimeSeries.LegendPlacement
    , TooltipMode = TimeSeries.TooltipMode
    , TooltipSort = TimeSeries.TooltipSort
    , CalcMode = TimeSeries.CalcMode
    }
