{ Utils = ./types/Utils.dhall
, Annotation =
  { default = ./defaults/Annotation.dhall, Type = ./types/Annotation.dhall }
, Dashboard =
  { default = ./defaults/Dashboard.dhall
  , Type = (./types/Dashboard.dhall).Type
  }
, DataLink =
  { default = ./defaults/DataLink.dhall, Type = ./types/DataLink.dhall }
, TimePicker =
  { default = ./defaults/TimePicker.dhall
  , Type = (./types/TimePicker.dhall).Type
  }
, StatPanelOptions =
        ./types/StatPanelOptions.dhall
    //  { default = ./defaults/StatPanelOptions.dhall }
, StatPanel =
  { default = (./defaults/StatPanel.dhall).StatPanel
  , Type = (./types/StatPanel.dhall).Type
  , PanelType = (./types/StatPanel.dhall).PanelType
  }
, StatPanels = ./types/StatPanel.dhall
, TextPanel =
  { default = ./defaults/TextPanel.dhall
  , Type = (./types/TextPanel.dhall).Type
  }
, TextPanels = ./types/TextPanel.dhall
, TimeSeriesPanel =
  { default = ./defaults/TimeSeriesPanel.dhall
  , Type = (./types/TimeSeriesPanel.dhall).Type
  , PanelType = (./types/TimeSeriesPanel.dhall).PanelType
  }
, BarChartPanel =
  { default = ./defaults/BarChartPanel.dhall
  , Type = (./types/BarChartPanel.dhall).Type
  , PanelType = (./types/BarChartPanel.dhall).PanelType
  }
, PieChartPanel =
  { default = ./defaults/PieChartPanel.dhall
  , Type = (./types/PieChartPanel.dhall).Type
  , PanelType = (./types/PieChartPanel.dhall).PanelType
  }
, HistogramPanel =
  { default = ./defaults/HistogramPanel.dhall
  , Type = (./types/HistogramPanel.dhall).Type
  , PanelType = (./types/HistogramPanel.dhall).PanelType
  }
, StateTimelinePanel =
  { default = ./defaults/StateTimelinePanel.dhall
  , Type = (./types/StateTimelinePanel.dhall).Type
  , PanelType = (./types/StateTimelinePanel.dhall).PanelType
  }
, StatusHistoryPanel =
  { default = ./defaults/StatusHistoryPanel.dhall
  , Type = (./types/StatusHistoryPanel.dhall).Type
  , PanelType = (./types/StatusHistoryPanel.dhall).PanelType
  }
, TablePanel =
  { default = ./defaults/TablePanel.dhall
  , Type = (./types/TablePanel.dhall).Type
  }
, DatasourceRef =
  { default = ./defaults/DatasourceRef.dhall
  , Type = ./types/DatasourceRef.dhall
  }
, PrometheusTarget =
  { default = ./defaults/PrometheusTarget.dhall
  , Type = (./types/PrometheusTarget.dhall).Type
  }
, PrometheusEditorMode = (./types/PrometheusTarget.dhall).EditorMode
, LokiTarget =
  { default = ./defaults/LokiTarget.dhall
  , Type = (./types/LokiTarget.dhall).Type
  }
, LokiEditorMode = (./types/LokiTarget.dhall).EditorMode
, LokiQueryType = (./types/LokiTarget.dhall).QueryType
, TestDataDBTarget =
  { default = ./defaults/TestDataDBTarget.dhall
  , Type = (./types/TestDataDBTarget.dhall).Type
  }
, Link =
  { Type = (./types/Link.dhall).Type, LinkType = (./types/Link.dhall).LinkType }
, LinkExternal =
  { default = (./defaults/Link.dhall).LinkExternal
  , Type = (./types/Link.dhall).Type
  }
, LinkDashboards =
  { default = (./defaults/Link.dhall).LinkDashboards
  , Type = (./types/Link.dhall).Type
  }
, Row = { default = ./defaults/Row.dhall, Type = (./types/Row.dhall).Type }
, GridPos = { default = ./defaults/GridPos.dhall, Type = ./types/GridPos.dhall }
, Timezone = (./types/Dashboard.dhall).Timezone
, Transformations =
  { default = (./types/Transformations.dhall).Types.Organize
  , Type = (./types/Transformations.dhall).Types
  }
, TransformationOrganize =
  { default = (./defaults/Transformations.dhall).Organize
  , Type = (./types/Transformations.dhall).Organize
  }
, Panels = ./types/Panels.dhall
, MetricsTargets = ./types/MetricTargets.dhall
, RawQueryTarget =
  { default = ./defaults/RawQueryTarget.dhall
  , Type = (./types/RawQueryTarget.dhall).Type
  }
, ScenarioId = (./types/TestDataDBTarget.dhall).ScenarioId
, TemplatingVariable = ./types/TemplatingVariable.dhall
, TemplatingVariableUtils = ./defaults/TemplatingVariable.dhall
, PrometheusTargetFormat = (./types/PrometheusTarget.dhall).FormatType
, FieldConfig =
  { default = (./defaults/FieldConfig.dhall).NullFieldConfig
  , Type = (./types/FieldConfig.dhall).Type
  , Override = (./types/FieldConfig.dhall).Override
  }
, FieldConfigs = ./types/FieldConfig.dhall
, ValueMapping = ./types/ValueMapping.dhall
, ValueMappingUtils = ./defaults/ValueMapping.dhall
, LuceneBucketSettings = ./schemas/LuceneBucketSettings.dhall
, LuceneTarget = ./schemas/LuceneTarget.dhall
}
