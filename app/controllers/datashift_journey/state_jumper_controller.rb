# This is a development tool - for creating and jumping straight to any State
#
# So that any data required for previous states can be created, it supports passing in a optional Factory
# that creates that data for you.
#
# The factory should return an instance of your DatashiftJourney.journey_plan_class
#
# For a full list of available factories you can call :
#
#   FactoryGirl.definition_file_paths.inspect
#
#   FactoryGirl.factories.collect(&:name).inspect
#
module DatashiftJourney
  class StateJumperController < ApplicationController

    unless Rails.env.production?

      require "factory_girl"
      require "faker"

      def build_and_display

        state =   params["state"]
        factory = params["factory"]

        journey_plan = if(factory)
                         # Get weird problems with factories with has_many associations, when they've already been used,
                         # so while obviously not very efficient, this seems to prevent that issue
                         FactoryGirl.reload

                         Rails.logger.debug(
                           "State jumper BUILDING #{DatashiftJourney.journey_plan_class} from factory [#{factory}]"
                         )

                         FactoryGirl.create(factory)
                       else
                         DatashiftJourney.journey_plan_class.create( state: state)
                       end

        Rails.logger.debug("State Jumper Using #{journey_plan.inspect}")

        Rails.logger.debug(journey_plan.state_paths.to_states)
        Rails.logger.debug(journey_plan.state_paths.events)

        if(journey_plan.state != state)
          journey_plan.next(state.to_sym) until(!journey_plan.can_next? || journey_plan.state == state)
        end

        journey_plan.update_attribute(:state, state) if(journey_plan.state != state)

        Rails.logger.debug("Jumping to STATE [#{journey_plan.state}]")

        redirect_to(datashift_journey.journey_plan_state_path(state, journey_plan)) && return
      end

    end
  end
end
