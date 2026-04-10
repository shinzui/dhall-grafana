let LinkType = < link | dashboards >

let DashboardLink =
      { title : Text
      , type : LinkType
      , icon : Text
      , tooltip : Text
      , url : Optional Text
      , tags : List Text
      , asDropdown : Bool
      , targetBlank : Bool
      , includeVars : Bool
      , keepTime : Bool
      }

in  { Type = DashboardLink, LinkType }
