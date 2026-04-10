let TextPanel = ../types/TextPanel.dhall

in  { id = 0
    , type = TextPanel.PanelType.text
    , options = { content = "# Default", mode = TextPanel.Mode.markdown }
    , links = [] : List (../types/Link.dhall).Type
    , repeat = None Text
    , repeatDirection = None ../types/Direction.dhall
    , maxPerRow = None Natural
    , transparent = False
    , transformations = [] : List (../types/Transformations.dhall).Types
    , fieldConfig = None (../types/FieldConfig.dhall).Type
    }
