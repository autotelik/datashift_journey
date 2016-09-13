class BaseForm < DatashiftJourney::BaseForm

  def initialize(model, journey_plan = nil)
    super(model, journey_plan)
  end

end

