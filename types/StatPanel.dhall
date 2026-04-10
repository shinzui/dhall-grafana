let PanelType = < stat | gauge >

let StatPanel =
          ./BasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional ./DatasourceRef.dhall
            , targets : List ./MetricTargets.dhall
            , options : (./StatPanelOptions.dhall).Type
            , timeFrom : Optional Text
            , timeShift : Optional Text
            , hideTimeOverride : Bool
            , maxDataPoints : Natural
            }

in  { Type = StatPanel, PanelType }
