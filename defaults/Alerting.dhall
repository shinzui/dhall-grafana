let Alerting = ../types/Alerting.dhall

in  { apiVersion = 1
    , groups = [] : List Alerting.AlertRuleGroup
    , deleteRules = [] : List Alerting.DeleteRule
    , contactPoints = [] : List Alerting.ContactPoint
    , deleteContactPoints = [] : List Alerting.DeleteContactPoint
    , policies = [] : List Alerting.Policy
    , resetPolicies = [] : List Natural
    , muteTimes = [] : List Alerting.MuteTime
    , deleteMuteTimes = [] : List Alerting.DeleteMuteTime
    , templates = [] : List Alerting.Template
    , deleteTemplates = [] : List Alerting.DeleteTemplate
    }
