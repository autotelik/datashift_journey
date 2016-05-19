module DatashiftState

  module Journey

    class Plan
      attr_accessor :journey_proc, :states

      def initialize( proc )
        @journey_proc = proc
        @states = []
      end

      def play
        instance_eval(&@journey_proc)

        DatashiftState.journey_plan_class.send :include, DatashiftState::JourneyPlanStateMachine
        DatashiftState.journey_plan_class.send :extend, DatashiftState::JourneyPlanStateMachine

        DatashiftState.journey_plan_class.class_eval do
          state_machine initial: DatashiftState.journey_plan_class.journey.first do
            @journey_proc.call
          end
        end

      end

      def sequence(*list)
        sequence_states = block_given? ? states(yield) : states(list)
        DatashiftState.journey_plan_class.class_eval do
          state_machine  do
            create_back_transitions(sequence_states)
            create_next_transitions(sequence_states)
          end
        end
      end

      def states( list )
        list.flatten!
        list.uniq!
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


    end

  end
end
