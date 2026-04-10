let Row = ../types/Row.dhall

in  { type = Row.PanelType.row
    , collapsed = False
    , id = 0
    , panels = [] : List {}
    , title = ""
    , gridPos = { x = 0, y = 0, w = 24, h = 1 }
    , repeat = None Text
    }
