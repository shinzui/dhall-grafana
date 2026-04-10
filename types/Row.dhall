let PanelType = < row >

let Row =
      { type : PanelType
      , collapsed : Bool
      , id : Natural
      , panels : List {}
      , title : Text
      , gridPos : ./GridPos.dhall
      , repeat : Optional Text
      }

in  { Type = Row, PanelType }
