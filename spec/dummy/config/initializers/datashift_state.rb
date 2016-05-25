DatashiftJourney.journey_plan_class = "Checkout"

DatashiftJourney::Configuration.configure do |config|
  config.partial_location = "journey_plans/states"

  config.use_null_form_when_no_form = true
end
