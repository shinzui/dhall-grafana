{-|
Latency CDF — the "before vs after" cumulative distribution chart.

A mean hides everything interesting about a latency change: a rollout can make
the typical request twice as fast while doubling the tail, and the mean will
report a mild regression that matches neither half. A CDF answers, for every
percentile at once, *what fraction of requests finished at or below x?* — so the
whole distribution is on one chart and the point where a change stops being a win
becomes visible as the two curves crossing.

The query needs no `histogram_quantile`: a Prometheus classic histogram's
`_bucket` series is *already* cumulative. Dividing each bucket by the total count
turns the counter into F(x) directly.

  sum by (le) (increase(metric_bucket[$__range])) / scalar(sum(increase(metric_count[$__range])))

The `+Inf` bucket is filtered out — it is always 1.0 and cannot be placed on a
finite axis, and converting the literal "+Inf" to a number would break the Trend
panel's ascending-x requirement.

## Parameters

* `metric` — the histogram's base name, without the `_bucket` / `_count` suffix.
* `matchers` — extra label matchers, e.g. `[ "job=\"api\"" ]`. Leave the list
  empty to aggregate every series in the histogram.
* `comparisonOffset` — how far back the "before" window sits. It is the same
  dashboard time range, shifted by this offset.

## Transformations

`le` arrives as a *string* label and the Trend panel refuses anything but an
ascending numeric x-field, so the chain converts it, joins the two windows into
one frame on it, names the value columns, and sorts.

The rename keys assume Grafana's frame-merge disambiguation (`Value #A` /
`Value #B`). If your Grafana version names them differently, open the panel,
switch to Table view, and adjust `renameByName` / `excludeByName` to match what
you actually see.

Adapted from Farid Zakaria, "The mean means nothing":
https://fzakaria.com/2026/07/27/the-mean-means-nothing
-}
let Grafana = ../package.dhall

let Prelude =
      https://prelude.dhall-lang.org/v20.1.0/package.dhall
        sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98

let FieldConfigs = Grafana.FieldConfigs

let TrendPanels = Grafana.TrendPanels

let Transformation = Grafana.Transformations.Type

let metric = "http_request_duration_seconds"

let matchers = [] : List Text

let comparisonOffset = "7d"

let datasource = Some { type = "prometheus", uid = "prometheus" }

let bucketSelector = Prelude.Text.concatSep ", " (matchers # [ "le!=\"+Inf\"" ])

let countSelector = Prelude.Text.concatSep ", " matchers

let cdfExpr
    : Text → Text
    = λ(offsetClause : Text) →
        ''
        sum by (le) (increase(${metric}_bucket{${bucketSelector}}[$__range]${offsetClause}))
        /
        scalar(sum(increase(${metric}_count{${countSelector}}[$__range]${offsetClause})))
        ''

let mkTarget =
      λ(refId : Text) →
      λ(offsetClause : Text) →
        Grafana.MetricsTargets.PrometheusTarget
          Grafana.PrometheusTarget::{
          , refId
          , expr = cdfExpr offsetClause
          , instant = True
          , range = False
          , format = Grafana.PrometheusTargetFormat.table
          , editorMode = Grafana.PrometheusEditorMode.code
          }

let transformations =
      [ Transformation.ConvertFieldType
          (   Grafana.TransformationConvertFieldType.default
            ⫽ { options.conversions
                =
                [ { targetField = "le"
                  , destinationType =
                      Grafana.TransformationDestinationType.number
                  , dateFormat = None Text
                  }
                ]
              }
          )
      , Transformation.JoinByField
          (   Grafana.TransformationJoinByField.default
            ⫽ { options =
                { byField = Some "le"
                , mode = Grafana.TransformationJoinMode.outer
                }
              }
          )
      , Transformation.Organize
          (   Grafana.TransformationOrganize.default
            ⫽ { options =
                { excludeByName = toMap
                    { `Time 1` = True
                    , `Time 2` = True
                    , `Time #A` = True
                    , `Time #B` = True
                    }
                , indexByName = Prelude.Map.empty Text Natural
                , renameByName = toMap
                    { `Value #A` = "After (this window)"
                    , `Value #B` = "Before (−${comparisonOffset})"
                    }
                }
              }
          )
      , Transformation.SortBy
          (   Grafana.TransformationSortBy.default
            ⫽ { options =
                { fields = {=}, sort = [ { field = "le", desc = False } ] }
              }
          )
      ]

let cdfBase = Grafana.TrendPanel.default

let cdfPanel =
      Grafana.Panels.mkTrendPanel
        (   cdfBase
          ⫽ { title = "Request latency CDF — before vs after"
            , gridPos = { x = 0, y = 0, w = 24, h = 14 }
            , datasource
            , targets =
              [ mkTarget "A" "", mkTarget "B" " offset ${comparisonOffset}" ]
            , transformations
            , options =
                  cdfBase.options
                ⫽ { xField = Some "le"
                  , legend = cdfBase.options.legend ⫽ { showLegend = True }
                  , tooltip =
                        cdfBase.options.tooltip
                      ⫽ { mode = TrendPanels.TooltipMode.multi
                        , sort = TrendPanels.TooltipSort.desc
                        }
                  }
            , fieldConfig =
                  cdfBase.fieldConfig
                ⫽ { defaults =
                        cdfBase.fieldConfig.defaults
                      ⫽ { color =
                          { fixedColor = None Text
                          , mode =
                              FieldConfigs.ColorMode.palette-classic-by-name
                          }
                        , unit = Some "percentunit"
                        , decimals = Some 1
                        , min = Some 0.0
                        , max = Some 1.0
                        , custom =
                              cdfBase.fieldConfig.defaults.custom
                            ⫽ { lineInterpolation =
                                  TrendPanels.LineInterpolation.stepAfter
                              , lineWidth = 2
                              , fillOpacity = 0
                              , showPoints = TrendPanels.ShowPoints.auto
                              , pointSize = 6
                              , axisLabel = "Fraction of requests ≤ x"
                              }
                        }
                  , overrides =
                    [ { matcher =
                        { id = FieldConfigs.MatcherID.byName, options = "le" }
                      , properties =
                        [ toMap { id = "unit", value = "s" }
                        , toMap
                            { id = "custom.axisLabel"
                            , value = "Request latency"
                            }
                        ]
                      }
                    ]
                  }
            }
        )

let readingGuide =
      ''
      ### How to read this

      The y-axis is **the fraction of requests that finished at or below the
      latency on the x-axis**. Each curve is one whole distribution, so every
      percentile is on the chart at once — read p50 across from 0.5, p99 from
      0.99.

      - **Curve shifted left** → more requests finishing faster.
      - **Curve shifted right** → more requests finishing slower.
      - **The curves cross** → the change is a win below the crossing latency and
        a loss above it. No single percentile can summarise it, and the mean will
        report whichever side happens to carry more weight.

      A step is one histogram bucket: resolution is bounded by your bucket
      boundaries, not by the panel.
      ''

let guidePanel =
      Grafana.Panels.mkTextPanel
        (   Grafana.TextPanel.default
          ⫽ { title = "Reading the CDF"
            , gridPos = { x = 0, y = 14, w = 24, h = 7 }
            , options =
              { content = readingGuide
              , mode = (../types/TextPanel.dhall).Mode.markdown
              }
            }
        )

let dashboard
    : Grafana.Dashboard.Type
    = Grafana.Dashboard::{
      , title = "Latency CDF"
      , uid = Some "dhall-grafana-latency-cdf"
      , panels = Grafana.Utils.generateIds [ cdfPanel, guidePanel ]
      , editable = True
      }

in  dashboard
