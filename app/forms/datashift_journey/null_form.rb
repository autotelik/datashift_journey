require_dependency 'reform'

# A specialized Form class for use with states that do not require Form functionality,
# just render the Partial

module DatashiftJourney
  class NullForm < BaseForm
    def self.factory(journey_plan)
      new(journey_plan)
    end

    def save
      true
    end

    def validate(_params)
      true
    end
  end
end
