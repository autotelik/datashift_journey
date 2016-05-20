module DatashiftState

  module StateMachines

    module Planner

      attr_accessor :last_processed_state, :next_split_state

      def sequence(*list)
        puts "IN sequence #{list}"
        flattened = list.flatten
        create_back_transitions flattened
        create_next_transitions flattened
        @last_processed_state = flattened.last
      end

      def split_on( state )
        puts "IN split_on #{state}"
        @next_split_state = state
        create_back(state, @last_processed_state)
      end

      def split( state, target_states, journey_plan_attr_reader, split_values)

        @last_processed_state

        raise "BadDefinition" unless(target_states.size == split_values.size)

        split_values.each_with_index do |v, i|
          at = -> { send(journey_plan_attr_reader) == v }

          create_back( state, target_states[i] )

          event :go_forward, steps.merge(if: at)
          event :go_back, steps.invert.merge(if: at)
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
