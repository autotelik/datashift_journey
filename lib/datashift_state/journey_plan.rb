module DatashiftState
  module  JourneyPlan

    # Array of StateMachines::Event
    def valid_for
      DatashiftState::JourneyPlan.state_machine.events.valid_for(self)
    end

    # This seems to successfully compare StateMachines::Event with strings
    def valid_for?(event)
      valid_for.include?(event)
    end

    def transitions_for
      DatashiftState::JourneyPlan.state_machine.events.transitions_for(self)
    end

    def next_state_name
      transitions_for.find { |t| t.event == :next }.try(:to_name)
    end

    def valid_state?(state_name)
      state_index(state_name.to_sym) != nil
    end

    # Expects a symbol
    # Returns nil when no such state
    def state_index(state)
      state.nil? ? nil : DatashiftState::JourneyPlan.state_names.index(state.to_sym)
    end

    def current_state_index
      DatashiftState::JourneyPlan.state_names.index(self.state_name).to_i
    end

    # Returns strings
    # Follows state_machine style, which returns a string for method :
    #     journey_plan.state
    #
    def self.states
      DatashiftState::JourneyPlan.state_names.map(&:to_s)
    end

    def states
      DatashiftState::JourneyPlan.states
    end

    # Returns symbols
    # Follows state_machine style, which returns a symbol for method :
    #     journey_plan.state_name
    #
    def self.state_names
      DatashiftState::JourneyPlan.state_machine.states.map(&:name)
    end


  end
end
