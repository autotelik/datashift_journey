module DatashiftJourney

  # Decorate a state machine enabled class with a set of extensions to :
  #
  #     https://github.com/state-machines/state_machines
  #     https://github.com/state-machines/state_machines-activerecord
  #
  module Journey

    module Extensions

      def transitions_for
        self.class.state_machine.events.transitions_for(self)
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
