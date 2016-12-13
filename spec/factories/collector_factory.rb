FactoryGirl.define do
  factory :collector, class: DatashiftJourney::Models::Collector do

    # N.B state must be a valid state from the defined journey
    # state :new_or_renew

=begin TODO - Good way to define a journey for RSepc
    DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do

      branch_sequence :new_sequence, [:business_type]

      branch_sequence :renew_sequence, [:enter_reg_number]
...
    end
=end

  end

end
