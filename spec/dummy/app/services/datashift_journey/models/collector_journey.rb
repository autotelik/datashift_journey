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
                     other_sequence: 'other',
                     sole_trader_sequence: 'sole_trader',
                     limited_company: 'limited_company',
  )

  branch_sequence :sole_trader_sequence, [:sole_trader_name, :business_details]

  branch_sequence :other_sequence, [:business_details]

  branch_sequence :limited_company, [:business_details]

  # RESTART COMMON JOURNEY AFTER BUSINESS TYPES

  sequence [
               :contact_details,
               :postal_address
           ]
end
