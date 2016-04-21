module DatashiftState
  mattr_accessor :journey_plan_class

  # Call DatashiftState.journey_plan_class = "Enrollment"

  def self.journey_plan_class=(x)
    @@journey_plan_class = x

    journey_plan_class.send :include, DatashiftState::JourneyPlan
  end

  def self.journey_plan_class
    if @@journey_plan_class.is_a?(Class)
      raise 'DatashiftState::Core.journey_plan_class MUST be a String or Symbol object, not a Class object.'
    elsif @@journey_plan_class.is_a?(String) || @@journey_plan_class.is_a?(Symbol)
      @@journey_plan_class.to_s.constantize
    end
  end

end
