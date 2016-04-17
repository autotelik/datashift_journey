module DatashiftState
  class JourneyPlan < ActiveRecord::Base
    extend SecureToken
    has_secure_token

    validates_presence_of :token, on: :save

    # STATE HELPERS

    # BACK - Create a 'back' event for each step (apart from first) in journey
    # You can exclude any other steps with the except list
    #
    def create_back_transitions( journey, except = [] )
      state_machine do
        journey.drop(1).each_with_index do |t, i|
          next if(except.include?(t))
          transition( {t => get_transitions[i - 1] }.merge(on: :back) )
        end
      end
    end


    # NEXT - Create a 'next' event for each step (apart from last) in journey
    # You can exclude  any other steps with the except list
    #
    def create_next_transitions( journey, except = [] ) )
      state_machine do
        journey[0...-1].each_with_index do |t, i|
          next if(except.include?(t))
          transition( { get_transitions[i] => get_transitions[i+1] }.merge(on: :next) )
        end
      end
    end

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

    def under_review?
      self.under_review == true
    end

    scope :created_between,   ->(start_date, end_date) { where(created_at: start_date..end_date) }
    scope :submitted_between, ->(start_date, end_date) { where(submitted_at: start_date..end_date) }

    def submitted?
      submitted_at.present?
    end

    def self.submitted
      where.not(submitted_at: nil)
    end

    def self.not_submitted
      where(submitted_at: nil)
    end
  end
end
