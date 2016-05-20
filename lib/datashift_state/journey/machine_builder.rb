module DatashiftState
  module Journey

    class MachineBuilder

      # N.B This gem is based on the AR integration
      # which uses the Machine name for the Column storing the state in
      # The default name and column is :state
      # Args
      #     :machine_name => :something_different     # Requires Class has a column called something_different
      #     :initial => :first_state
      #
      def self.build(args = {}, &block)
        klass = DatashiftState.journey_plan_class

        machine_name = args.has_key?(:machine_name) ? args.delete(:machine_name) : :state

        puts "Building Machine for [#{klass}]"

        machine = if(block_given?)
                    klass.class_eval do
                      state_machine machine_name, args do
                        instance_eval(&block)   # sets the context to be StateMachine class'
                      end
                    end
                  else
                    ::StateMachines::Machine.new(klass, machine_name, args)
                  end

        machine

      end

    end

  end
end
