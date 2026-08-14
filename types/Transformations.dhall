{-|
Panel transformations — the client-side pipeline Grafana runs over query results
before handing them to a visualisation.

* `Organize` (`organize`) reorders, renames, and hides fields.

* `ConvertFieldType` (`convertFieldType`) reinterprets a field's data type. The
  common need is turning a label that arrived as text — a Prometheus `le` bucket
  boundary, say — into a number so a numeric axis will accept it.

* `JoinByField` (`joinByField`) merges several frames into one on a shared field,
  the way a SQL JOIN does. `outer` is the classic mode and suits an ascending
  numeric key; `outerTabular` handles tabular data whose key repeats.

* `SortBy` (`sortBy`) orders rows by a field. Panels that plot against a numeric
  x-axis require ascending values and error out otherwise, so this usually
  follows a `ConvertFieldType`.

Note that `dhall format` discards every comment except a file's leading block,
which is why these live here rather than beside each declaration.
-}
let Prelude =
      https://prelude.dhall-lang.org/v20.1.0/package.dhall
        sha256:26b0ef498663d269e4dc6a82b0ee289ec565d683ef4c00d0ebdd25333a5a3c98

let Organize =
      { id : Text
      , options :
          { excludeByName : Prelude.Map.Type Text Bool
          , indexByName : Prelude.Map.Type Text Natural
          , renameByName : Prelude.Map.Type Text Text
          }
      }

let DestinationType = < string | number | time | boolean | enum >

let Conversion =
      { targetField : Text
      , destinationType : DestinationType
      , dateFormat : Optional Text
      }

let ConvertFieldType =
      { id : Text, options : { conversions : List Conversion } }

let JoinMode = < outer | outerTabular | inner >

let JoinByField =
      { id : Text, options : { byField : Optional Text, mode : JoinMode } }

let SortByField = { field : Text, desc : Bool }

let SortBy = { id : Text, options : { fields : {}, sort : List SortByField } }

let Types =
      < Organize : Organize
      | ConvertFieldType : ConvertFieldType
      | JoinByField : JoinByField
      | SortBy : SortBy
      >

in  { Types
    , Organize
    , ConvertFieldType
    , Conversion
    , DestinationType
    , JoinByField
    , JoinMode
    , SortBy
    , SortByField
    }
