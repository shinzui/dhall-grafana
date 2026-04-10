let MetricTargets = ./MetricTargets.dhall

let PanelType = < table >

let TablePanel =
          ./BasePanel.dhall
      //\\  { type : PanelType
            , datasource : Optional ./DatasourceRef.dhall
            , targets : List MetricTargets
            , options : {}
            , timeFrom : Optional Text
            , timeShift : Optional Text
            , hideTimeOverride : Bool
            }

in  { Type = TablePanel, PanelType }
