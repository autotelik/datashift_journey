module DatashiftJourney
  module Journey

    class MachineBuilder

      # The available API is defined in :
      #
      #     datashift_journey/lib/datashift_journey/state_machines/planner.rb
      #
      # N.B This gem is based on the AR integration which uses the Machine name for the Column storing the state in
      # The default name and column is :state
      #
      # Args
      #     :machine_name => :something_different     # Requires Class has a string column also called something_different
      #     :initial => :first_state
      #
      def self.create_journey_plan(args = {}, &block)
        create_journey_plan_for(DatashiftJourney.journey_plan_class, args, &block)
      end

      # N.B This gem is based on the AR integration which uses the Machine name for the Column storing the state in
      # The default name and column is :state
      #
      # Args
      #     :machine_name => :something_different     # Requires Class has a column called something_different
      #     :initial => :first_state
      #
      def self.create_journey_plan_for(klass, args = {}, &block)
        machine_name = args.key?(:machine_name) ? args.delete(:machine_name) : :state

        puts "Building journey plan State Machine [#{machine_name}] for [#{klass}]"

        machine = if block_given?
                    klass.class_eval do
                      state_machine machine_name, args do
                        instance_eval(&block) # sets the context to be StateMachine class'

                        # Journey has been pre parsed, we have the states, - now build navigation events and transitions
                        instance_eval('build_journey_plan')
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
