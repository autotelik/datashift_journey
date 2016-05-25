require_dependency "reform"

# A specialized Form class for use with states that do not require Form functionality,
# just render the Partial

module DatashiftJourney
  class NullForm < ::Reform::Form
    def self.factory(journey_plan)
      new(journey_plan)
    end

    attr_reader :journey_plan

    def initialize(model, journey_plan = nil)
      @journey_plan = journey_plan || model
      super(model)
    end

    def save
      true
    end

    def validate(_params)
      true
    end
  end
end
