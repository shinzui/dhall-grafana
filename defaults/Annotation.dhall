let Annotation = ../types/Annotation.dhall

in    { builtIn = 1
      , datasource = { type = "grafana", uid = "-- Grafana --" }
      , enable = True
      , hide = True
      , iconColor = "rgba(0, 211, 255, 1)"
      , name = "Annotations & Alerts"
      , type = "dashboard"
      }
    : Annotation
