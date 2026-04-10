let Prelude =
      https://prelude.dhall-lang.org/v20.1.0/package.dhall
        sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98

let DataLink = ./DataLink.dhall

let ValueMapping = (./ValueMapping.dhall).Type

let ColorMode =
      < fixed
      | thresholds
      | palette-classic
      | palette-classic-by-name
      | continuous-GrYlRd
      | continuous-RdYlGr
      | continuous-BlYlRd
      | continuous-YlRd
      | continuous-BlPu
      | continuous-YlBl
      | continuous-blues
      | continuous-reds
      | continuous-greens
      | continuous-purples
      | shades
      >

let ThresholdMode = < absolute | percentage >

let MatcherID = < byName | byType | byRegexp | byFrameRefID >

let ThresholdStep = { color : Text, value : Double }

let Defaults =
      { color : { fixedColor : Optional Text, mode : ColorMode }
      , custom : {}
      , unit : Optional Text
      , decimals : Optional Natural
      , displayName : Optional Text
      , min : Optional Double
      , max : Optional Double
      , noValue : Optional Text
      , links : List DataLink
      , mappings : List ValueMapping
      , thresholds : { mode : ThresholdMode, steps : List ThresholdStep }
      }

let Override =
      { matcher : { id : MatcherID, options : Text }
      , properties : List (Prelude.Map.Type Text Text)
      }

let FieldConfig = { defaults : Optional Defaults, overrides : List Override }

let mkDefaults =
      \(color : { fixedColor : Optional Text, mode : ColorMode }) ->
      \(baseThresholdColor : Text) ->
      \(thresholdMode : ThresholdMode) ->
      \(steps : List { color : Text, value : Double }) ->
        Some
          { color
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
            { mode = thresholdMode
            , steps = [ { color = baseThresholdColor, value = 0.0 } ] # steps
            }
          }

in  { Type = FieldConfig
    , ColorMode
    , ThresholdMode
    , MatcherID
    , Defaults
    , Override
    , ThresholdStep
    , mkDefaults
    }
