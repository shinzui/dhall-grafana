let Link = ../types/Link.dhall

let LinkDashboards =
      { title = "Dashboards"
      , type = Link.LinkType.dashboards
      , icon = "external link"
      , tooltip = ""
      , url = None Text
      , tags = [] : List Text
      , asDropdown = True
      , targetBlank = False
      , includeVars = False
      , keepTime = False
      }

let LinkExternal =
      { title = "External"
      , type = Link.LinkType.link
      , icon = "external link"
      , tooltip = ""
      , url = Some ""
      , tags = [] : List Text
      , asDropdown = False
      , targetBlank = True
      , includeVars = False
      , keepTime = False
      }

in  { LinkDashboards, LinkExternal }
