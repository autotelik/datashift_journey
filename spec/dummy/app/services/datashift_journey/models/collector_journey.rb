DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do

  branch_sequence :new_sequence, [:business_type]

  branch_sequence :renew_sequence, [:enter_reg_number]

  # now define the parent state and the routing criteria to each sequence

  split_on_equality( :new_or_renew,
                     "new_or_renew_value",    # Helper method on Collector
                     new_sequence: 'new',
                     renew_sequence: 'renew'
  )


  # Define the sequences for Business Type split
  # Partnership Limited Company Public Body Charity Authority Other

  split_on_equality( :business_type,
                     "business_type_value",    # Helper method on Collector,
                     authority:  'authority',
                     other_sequence: 'other',
                     sole_trader_sequence: 'sole_trader',
                     partnership_sequence: 'partnership',
                     limited_company: 'limited_company',
                     public_body:  'public_body',
                     charity: 'charity'
  )

  # SOLE TRADER
  branch_sequence :sole_trader_sequence, [:other_businesses, :service_provided]

  split_on_equality( :service_provided,
                     "service_provided_value",    # Helper method on Collector
                     service_provided_no_sequence: 'no',
                     service_provided_yes_sequence: 'yes'
  )

  branch_sequence :service_provided_no_sequence, []  # => construction_demolition

  # OTHER

  branch_sequence :other_sequence, [:other_business]


  # Construction Demolition

  split_on_equality( :construction_demolition,
                     :construction_demolition_value,
                     registration_type_sequence: 'yes',  # => registration_type
  )

  # This branch may actually simplify down to just
  # sequence [ :registration_type, :business_details]

  split_on_equality( :registration_type,
                     :registration_type_value,
                     carrier_dealer_sequence: 'carrier_dealer',
                     broker_dealer_sequence: 'broker_dealer',
                     carrier_broker_dealer_sequence: 'carrier_broker_dealer'
  )

  branch_sequence :carrier_dealer_sequence, [:business_details]
  branch_sequence :broker_dealer_sequence, [:business_details]
  branch_sequence :carrier_broker_dealer_sequence, [:business_details]

  # RESTART COMMON JOURNEY AFTER BUSINESS TYPES

  sequence [
               :contact_details,
               :postal_address
           ]
end
