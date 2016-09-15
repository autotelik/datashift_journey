module DatashiftJourney
  mattr_accessor :journey_plan_class

  # Default
  @@journey_plan_class = "DatashiftJourney::Collector"

  def self.journey_plan_class=(x)
    @@journey_plan_class = x

    Rails.logger.info "Auto Extend #{x} with DatashiftJourney StateMachine"
  end

  def self.journey_plan_class
    if @@journey_plan_class.is_a?(Class)
      raise 'DatashiftJourney::Core.journey_plan_class MUST be a String or Symbol object, not a Class object.'
    elsif @@journey_plan_class.is_a?(String) || @@journey_plan_class.is_a?(Symbol)
      @@journey_plan_class.to_s.constantize
    end
  end

end
