let FieldConfig = ./FieldConfig.dhall

let DataLink = ./DataLink.dhall

let ValueMapping = (./ValueMapping.dhall).Type

let ModernFieldConfig =
      λ(Custom : Type) →
        { defaults :
            { color :
                { fixedColor : Optional Text, mode : FieldConfig.ColorMode }
            , custom : Custom
            , unit : Optional Text
            , decimals : Optional Natural
            , displayName : Optional Text
            , min : Optional Double
            , max : Optional Double
            , noValue : Optional Text
            , links : List DataLink
            , mappings : List ValueMapping
            , thresholds :
                { mode : FieldConfig.ThresholdMode
                , steps : List FieldConfig.ThresholdStep
                }
            }
        , overrides : List FieldConfig.Override
        }

in  ModernFieldConfig
