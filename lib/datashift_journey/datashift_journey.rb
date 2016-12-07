module DatashiftJourney

  def self.journey_plan_class=(x)
    @journey_plan_class = x

    Rails.logger.info "Auto Extend #{x} with DatashiftJourney StateMachine"
  end

  def self.journey_plan_class
    @journey_plan_class ||= default_journey_plan_class_name

    if @journey_plan_class.is_a?(Class)
      raise 'DatashiftJourney::Core.journey_plan_class MUST be a String or Symbol object, not a Class object.'
    elsif @journey_plan_class.is_a?(String) || @journey_plan_class.is_a?(Symbol)
      @journey_plan_class.to_s.constantize
    end
  end

  def self.use_default_journey_plan_class
    DatashiftJourney.journey_plan_class = DatashiftJourney.default_journey_plan_class_name
  end

  def self.default_journey_plan_class_name
    'DatashiftJourney::Models::Collector'
  end

end
