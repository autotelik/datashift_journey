DatashiftJourney.journey_plan_class = 'TestPlanModel'

DatashiftJourney::Configuration.configure do |config|
  config.partial_location = 'datashift_journey/models/collectors'

  config.add_state_jumper_toolbar = false
  config.state_jumper_states = {}
end

# For Form validation options see - https://github.com/trailblazer/reform#installation
#
require "reform/form/dry"

Reform::Form.class_eval do
  feature Reform::Form::Dry
end

