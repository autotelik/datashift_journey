module DatashiftState

  module StateMachines

    module Planner

      def sequence(*list)
        sequence_states = block_given? ? yield : list

        puts "IN SEQ #{self} : #{sequence_states.inspect}"
        create_back_transitions(sequence_states)
        create_next_transitions(sequence_states)
      end

      def split_on( state, target_states, journey_plan_attr_reader, split_values)

        raise "BadDefinition" unless(target_states.size == split_values.size)

        split_values.each_with_index do |v, i|
          at = -> { send(journey_plan_attr_reader) == v }

          create_back( state, target_states[i] )

          event :go_forward, steps.merge(if: at)
          event :go_back, steps.invert.merge(if: at)
        end

      end

      def split( id )
        yield
      end

      def combine_on(id)
        yield
      end

      def split_on( state )
        puts "IN SPLIT_ON", state.inspect
        add_states(id)
      end

      def split( id , *list)
        puts "IN SEQUENCE", list.inspect
        block_given? ? add_states(yield) : add_states(list)
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
