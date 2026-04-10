let Prelude =
      https://prelude.dhall-lang.org/v20.1.0/package.dhall
        sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98

let MappingResult =
      { text : Optional Text, color : Optional Text, index : Natural }

let ValueMap = { type : Text, options : Prelude.Map.Type Text MappingResult }

let RangeMap =
      { type : Text
      , options : { from : Double, to : Double, result : MappingResult }
      }

let RegexMap =
      { type : Text, options : { pattern : Text, result : MappingResult } }

let SpecialValueMap =
      { type : Text, options : { match : Text, result : MappingResult } }

let ValueMapping =
      < ValueMap : ValueMap
      | RangeMap : RangeMap
      | RegexMap : RegexMap
      | SpecialValueMap : SpecialValueMap
      >

in  { Type = ValueMapping
    , ValueMap
    , RangeMap
    , RegexMap
    , SpecialValueMap
    , MappingResult
    }
