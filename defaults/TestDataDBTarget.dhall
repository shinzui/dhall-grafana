let DatasourceRef = ../types/DatasourceRef.dhall

let ScenarioId = (../types/TestDataDBTarget.dhall).ScenarioId

in  { scenarioId = ScenarioId.random_walk, datasource = None DatasourceRef }
