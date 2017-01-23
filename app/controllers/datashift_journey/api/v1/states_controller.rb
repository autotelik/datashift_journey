module DatashiftJourney
  module Api
    module V1

      class StatesController < ActionController::API

        def index

          state_paths = []

          DatashiftJourney.journey_plan_class.new.state_paths.each_with_index do |s, i|
            state_paths << {
                index: i, events: s.events, from_name: s.from_name, to_name: s.to_name
            }
          end

          states = DatashiftJourney.journey_plan_class.state_machine.states.collect do |s|
            {
                name: s.name, value: s.value, initial: s.initial, final: s.final?
            }
          end

          events = DatashiftJourney.journey_plan_class.state_machine.events.collect do |e|
            {
                #machine: s.machine,
                name: e.name,
                qualified_name: e.qualified_name,
                human_name: e.human_name,
                branches: e.branches,
                known_states: e.known_states,

                transitions: e.branches.map do |branch|
                  branch.state_requirements.map do |state_requirement|
                    {state_requirement: state_requirement, from: state_requirement[:from].class, to: state_requirement[:to]}
                  end
                end
            }
          end

          render json: { data:
                             {
                                 states: states, state_paths: state_paths, events: events
                             }
          }
        end
      end
    end
  end
end