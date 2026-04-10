let Mode = < html | markdown | code >

let PanelType = < text >

let TextPanelOptions = { content : Text, mode : Mode }

let TextPanel =
      ./BasePanel.dhall //\\ { type : PanelType, options : TextPanelOptions }

in  { Type = TextPanel, Mode, PanelType, Options = TextPanelOptions }
