let FieldConfig = ../types/FieldConfig.dhall

let DataLink = ../types/DataLink.dhall

let ValueMapping = (../types/ValueMapping.dhall).Type

let NullFieldConfig =
      { defaults = None FieldConfig.Defaults
      , overrides = [] : List FieldConfig.Override
      }

let DefaultFieldConfig =
      { defaults = Some
        { color =
          { fixedColor = None Text
          , mode = FieldConfig.ColorMode.palette-classic
          }
        , custom = {=}
        , unit = None Text
        , decimals = None Natural
        , displayName = None Text
        , min = None Double
        , max = None Double
        , noValue = None Text
        , links = [] : List DataLink
        , mappings = [] : List ValueMapping
        , thresholds =
          { mode = FieldConfig.ThresholdMode.absolute
          , steps =
            [ { color = "green", value = None Double }
            , { color = "red", value = Some 80.0 }
            ]
          }
        }
      , overrides = [] : List FieldConfig.Override
      }

in  { NullFieldConfig, DefaultFieldConfig }
