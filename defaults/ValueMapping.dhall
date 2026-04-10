let Prelude =
      https://prelude.dhall-lang.org/v20.1.0/package.dhall
        sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98

let VM = ../types/ValueMapping.dhall

let mkValueMap =
      \(options : Prelude.Map.Type Text VM.MappingResult) ->
        VM.Type.ValueMap { type = "value", options }

let mkRangeMap =
      \(from : Double) ->
      \(to : Double) ->
      \(result : VM.MappingResult) ->
        VM.Type.RangeMap { type = "range", options = { from, to, result } }

let mkRegexMap =
      \(pattern : Text) ->
      \(result : VM.MappingResult) ->
        VM.Type.RegexMap { type = "regex", options = { pattern, result } }

let mkSpecialValueMap =
      \(match : Text) ->
      \(result : VM.MappingResult) ->
        VM.Type.SpecialValueMap
          { type = "special", options = { match, result } }

in  { mkValueMap, mkRangeMap, mkRegexMap, mkSpecialValueMap }
