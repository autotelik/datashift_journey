
DatashiftJourney.journey_plan_class = 'DatashiftJourney::Collector::Collector'

DatashiftJourney::Configuration.configure do |config|
  config.partial_location = 'datashift_journey/models/collectors'
end
