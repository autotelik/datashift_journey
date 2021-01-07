class TestPlanModel < ApplicationRecord
  include DatashiftJourney::ReferenceGenerator.new(prefix: 'C')

  include DatashiftJourney::Collector::PlanConcern

  # Helpers used in determining which branch to travel
  attr_accessor :business_type_value, :new_or_renew_value, :registration_type_value, :service_provided_value

end
