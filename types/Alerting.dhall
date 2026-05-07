let NoDataState = < NoData | Alerting | OK >

let ExecErrState = < Error | Alerting | OK >

let DatasourceRef = { type : Text, uid : Text }

let RelativeTimeRange = { from : Natural, to : Natural }

let ExpressionModel =
      { datasource : DatasourceRef
      , expression : Text
      , intervalMs : Natural
      , maxDataPoints : Natural
      , refId : Text
      , type : Text
      }

let AlertQuery =
      { refId : Text
      , relativeTimeRange : RelativeTimeRange
      , datasourceUid : Text
      , model : ExpressionModel
      }

let AlertRule =
      { uid : Text
      , title : Text
      , condition : Text
      , data : List AlertQuery
      , noDataState : NoDataState
      , execErrState : ExecErrState
      , for : Text
      , annotations : List { mapKey : Text, mapValue : Text }
      , labels : List { mapKey : Text, mapValue : Text }
      , isPaused : Bool
      }

let AlertRuleGroup =
      { orgId : Natural
      , name : Text
      , folder : Text
      , interval : Text
      , rules : List AlertRule
      }

let DeleteRule = { orgId : Natural, uid : Text }

let Receiver =
      { uid : Text
      , type : Text
      , settings : List { mapKey : Text, mapValue : Text }
      , disableResolveMessage : Bool
      }

let ContactPoint = { orgId : Natural, name : Text, receivers : List Receiver }

let DeleteContactPoint = { orgId : Natural, uid : Text }

let Matcher = List Text

let Route =
      { receiver : Text
      , object_matchers : List Matcher
      , mute_time_intervals : List Text
      , continue : Bool
      }

let Policy =
      { orgId : Natural
      , receiver : Text
      , group_by : List Text
      , routes : List Route
      }

let TimeInterval =
      { weekdays : List Text
      , times : List { start_time : Text, end_time : Text }
      , location : Text
      }

let MuteTime =
      { orgId : Natural, name : Text, time_intervals : List TimeInterval }

let DeleteMuteTime = { orgId : Natural, name : Text }

let Template = { orgId : Natural, name : Text, template : Text }

let DeleteTemplate = { orgId : Natural, name : Text }

let AlertingType =
      { apiVersion : Natural
      , groups : List AlertRuleGroup
      , deleteRules : List DeleteRule
      , contactPoints : List ContactPoint
      , deleteContactPoints : List DeleteContactPoint
      , policies : List Policy
      , resetPolicies : List Natural
      , muteTimes : List MuteTime
      , deleteMuteTimes : List DeleteMuteTime
      , templates : List Template
      , deleteTemplates : List DeleteTemplate
      }

in  { Type = AlertingType
    , NoDataState
    , ExecErrState
    , DatasourceRef
    , RelativeTimeRange
    , ExpressionModel
    , AlertQuery
    , AlertRule
    , AlertRuleGroup
    , DeleteRule
    , Receiver
    , ContactPoint
    , DeleteContactPoint
    , Matcher
    , Route
    , Policy
    , TimeInterval
    , MuteTime
    , DeleteMuteTime
    , Template
    , DeleteTemplate
    }
