module DatashiftJourney
  module Api
    module V1

      class StatesController < ActionController::API

        def index

          states = DatashiftJourney.journey_plan_class.state_machine.states.collect do |s|
            {
              name: s.name, value: s.value, initial: s.initial
            }
          end

          events = DatashiftJourney.journey_plan_class.state_machine.events.collect do |s|
            {
                #machine: s.machine,
                name: s.name,
                qualified_name: s.qualified_name,
                human_name: s.human_name,
                branches: s.branches,
                #known_states: s.known_states
            }
          end

          render json: { data:
                           {
                             states: states, events: events
                           }
          }
        end
      end
    end
  end
end