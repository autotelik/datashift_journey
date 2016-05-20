module DatashiftState

  # Decorate a state machine enabled class with a set of extensions to :
  #
  #     https://github.com/state-machines/state_machines
  #     https://github.com/state-machines/state_machines-activerecord
  #
  module Journey

    module Extensions
=begin
      # Array of StateMachines::Event
      def valid_for
        DatashiftState.journey_plan_class.state_machine.events.valid_for(self)
      end

      # This seems to successfully compare StateMachines::Event with strings
      def valid_for?(event)
        valid_for.include?(event)
      end

      def transitions_for
        events.transitions_for(self)
      end

      def next_state_name
        transitions_for.find { |t| t.event == :next }.try(:to_name)
      end

      def previous_state_name
        transitions_for.find { |t| t.event == :back }.try(:to_name)
      end

      def valid_state?(state_name)
        state_index(state_name.to_sym) != nil
      end

      # Expects a symbol
      # Returns nil when no such state
      def state_index(state)
        state.nil? ? nil : DatashiftState.journey_plan_class.state_names.index(state.to_sym)
      end

      def current_state_index
        DatashiftState.journey_plan_class.state_names.index(state_name).to_i
      end

      extend self

      # Returns symbols
      # Follows state_machine style, which returns a symbol for method :
      #     journey_plan.state_name
      #
      def state_names
        state_machine.states.map(&:name)
      end

      # Returns strings
      # Follows state_machine style, which returns a string for method :
      #     journey_plan.state
      #
      def states
        DatashiftState.journey_plan_class.state_names.map(&:to_s)
      end
=end
    end
  end
end
