module DatashiftState
  module Journey

    class Plan

      def self.build(name, initial, &block)
        puts "BUILD Plan for [#{DatashiftState.journey_plan_class}]"

        state_machine_klass = DatashiftState.journey_plan_class

        state_machine_klass.class_eval do
          state_machine initial: initial do
            instance_eval(&block)   # sets the context to be StateMachine class'
          end
        end
      end

    end

  end
end
