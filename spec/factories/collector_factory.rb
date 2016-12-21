FactoryGirl.define do
  factory :collector, class: DatashiftJourney::Collector::Collector do
    reference FFaker::Product.model
    # N.B state must be a valid state from the defined journey
    # state :new_or_renew

    # TODO: - Good way to define a journey for RSepc
    #     DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do
    #
    #       branch_sequence :new_sequence, [:business_type]
    #
    #       branch_sequence :renew_sequence, [:enter_reg_number]
    # ...
    #     end
  end
end
