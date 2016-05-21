module DatashiftState

  module StateMachines

    module Planner

      attr_accessor :last_processed_state

      attr_accessor :split_state

      def sequence(*list)
        puts "IN sequence #{list}"
        flattened = list.flatten
        create_back_transitions flattened
        create_next_transitions flattened

        create_next(@last_processed_state,  flattened.last) if(@last_processed_state)

        @last_processed_state = flattened.last
        @split_state = nil
      end

      def split_on( state )
        puts "IN split_on #{state}"
        @split_state = state

        create_back(state, @last_processed_state)
        create_next(@last_processed_state, state)

        @last_processed_state = state
      end

      def split_on_equality(target_states, journey_plan_attr_reader, split_values)
        puts "IN split_on_equality #{target_states}"

        raise "No split_on defined before the spolit" unless split_state

        # Each target state has a back transition to last split_on state
        target_states.each { |t| create_back(t, split_state) }

        raise "BadDefinition" unless(target_states.size == split_values.size)

        split_values.each_with_index do |v, i|
          at = -> { send(journey_plan_attr_reader) == v }
          create_next( split_state, target_states[i] ) do at end
        end

      end

      def combine_on(id)
        puts "IN COMBINE_ON", id.inspect
        add_states(id)
      end

      private

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

    end
  end
end
