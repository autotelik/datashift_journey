DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do

  # the parent state and the routing criteria to each sequence

  split_on_equality( :new_or_renew,
                     "new_or_renew_value",    # Helper method on Collector
                     new_sequence: 'new',
                     renew_sequence: 'renew'
  )

  branch_sequence :new_sequence, [:business_type]

  branch_sequence :renew_sequence, [:enter_reg_number]

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

DatashiftJourney::Collector::Collector.class_eval do
  def new_or_renew_value
    'new'
  end

  def business_type_value
    'sole_trader'
  end

  def service_provided_value
    'no'
  end
end
