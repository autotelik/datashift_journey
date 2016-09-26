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

      require 'factory_girl'
      require 'faker'

      def build_and_display
        state =   params['state']
        factory = params['factory']

        plan = if factory
                 # Get weird problems with factories with has_many associations, when they've already been used,
                 # so while obviously not very efficient, this seems to prevent that issue
                 FactoryGirl.reload

                 Rails.logger.debug("Building StateJumper #{DatashiftJourney.journey_plan_class} from [#{factory}]")

                 FactoryGirl.create(factory)
               else
                 DatashiftJourney.journey_plan_class.create(state: state)
               end

        if plan.state != state
          plan.next(state.to_sym) until !plan.can_next? || plan.state == state
        end

        plan.update_attribute(:state, state) if plan.state != state

        Rails.logger.debug("Jumping to STATE [#{plan.state}]")

        redirect_to(datashift_journey.journey_plan_state_path(state, plan)) && return
      end

    end
  end
end
