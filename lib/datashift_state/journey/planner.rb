module DatashiftState

  module Journey

    def sequence(*list)
      sequence_states = block_given? ? states(yield) : states(list)


      puts self.inspect, self.class
      create_back_transitions(sequence_states)
      create_next_transitions(sequence_states)

    end

    class Planner

      attr_accessor :plans

      attr_accessor :current_plan

      def initialize
        @plans = Journey::Planner.hash_klass.new
        @current_plan = nil
      end

      def create(name, &block)
        @current_plan = Journey::Plan.new( block )
        plans[name] ||= @current_plan

        @current_plan.play

        @current_plan
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

      def build_machine
        owning_klass = DatashiftState.journey_plan_class

        DatashiftState.journey_plan_class.class_eval do
          state_machine initial: owning_klass.journey.first do

            create_back_transitions(DatashiftState.journey_plan_class.journey, [:complete])

            create_next_transitions(DatashiftState.journey_plan_class.journey)
          end
        end
      end

      private

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

    end
  end
end
