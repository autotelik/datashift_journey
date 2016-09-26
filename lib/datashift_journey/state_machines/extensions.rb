# Decorate a state machine enabled class with a set of extensions to :
#
#     https://github.com/state-machines/state_machines
#     https://github.com/state-machines/state_machines-activerecord
#
module DatashiftJourney

  module StateMachines

    module Extensions

      def transitions_for
        self.class.state_machine.events.transitions_for(self)
      end

      # Expects a symbol
      # Returns nil when no such state
      def state_index(state)
        state.nil? ? nil : state_paths.to_states.index(state.to_sym).to_i
      end

      def current_state_index
        state_paths.to_states.index(state_name).to_i
      end

      def next_state_name
        transitions_for.find { |t| t.event == :next }.try(:to_name)
      end

      def previous_state_name
        transitions_for.find { |t| t.event == :back }.try(:to_name)
      end

    end
  end
end
