require 'rails_helper'

module DatashiftJourney

  module Journey

    RSpec.describe 'Complex Machine Builder Examples' do
      before(:each) do
        DatashiftJourney.use_default_journey_plan_class
        # puts DatashiftJourney.journey_plan_class.state_machine.methods.sort
        # puts DatashiftJourney.journey_plan_class.state_machine

        # N.B This is bit of a hack cos DatashiftJourney.journey_plan_class.state_machines
        # only available after at least one Machine defined

        DatashiftJourney.journey_plan_class.state_machines.clear if DatashiftJourney.journey_plan_class.respond_to?(:state_machines)
      end

      context 'Multiple Sequences' do
        it 'reports that branches are missing when not defined' do
          pending('create a test with a splitter but where some branch_sequences are not defined')

          DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :splitter) do
            branch_sequence :renew_sequence, [:business_type]

            split_on_equality(:splitter,
                              'new_or_renew_value', # Helper method on Collector
                              new_sequence: 'new',
                              renew_sequence: 'renew')
          end

          journey = DatashiftJourney.journey_plan_class.new

          expect_state_matches(journey, :new_or_renew)
          expect(journey.can_back?).to eq false # this is the initial state

          journey.next!
        end

        it 'enables the first state to be a branch splitter' do
          DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do
            branch_sequence :new_sequence, [:business_type]

            branch_sequence :renew_sequence, [:enter_reg_number]

            # now define the parent state and the routing criteria to each sequence

            split_on_equality(:new_or_renew,
                              'new_or_renew_value', # Helper method on Collector
                              new_sequence: 'new',
                              renew_sequence: 'renew')

            # Define the sequences for Business Type split
            # Partnership Limited Company Public Body Charity Authority Other

            split_on_equality(:business_type,
                              'business_type_value', # Helper method on Collector,
                              authority:  'authority',
                              other_sequence: 'other',
                              sole_trader_sequence: 'sole_trader',
                              partnership_sequence: 'partnership',
                              limited_company: 'limited_company',
                              public_body:  'public_body',
                              charity: 'charity')

            # SOLE TRADER
            branch_sequence :sole_trader_sequence, [:other_businesses, :service_provided]

            split_on_equality(:service_provided,
                              'service_provided_value', # Helper method on Collector
                              service_provided_no_sequence: 'no',
                              service_provided_yes_sequence: 'yes')

            branch_sequence :service_provided_no_sequence, [] # => construction_demolition

            # OTHER

            branch_sequence :other_sequence, [:other_business]

            # Construction Demolition

            split_on_equality(:construction_demolition,
                              :construction_demolition_value,
                              registration_type_sequence: 'yes') # => registration_type

            # This branch may actually simplify down to just
            # sequence [ :registration_type, :business_details]

            split_on_equality(:registration_type,
                              :registration_type_value,
                              carrier_dealer_sequence: 'carrier_dealer',
                              broker_dealer_sequence: 'broker_dealer',
                              carrier_broker_dealer_sequence: 'carrier_broker_dealer')

            branch_sequence :carrier_dealer_sequence, [:business_details]
            branch_sequence :broker_dealer_sequence, [:business_details]
            branch_sequence :carrier_broker_dealer_sequence, [:business_details]

            # RESTART COMMON JOURNEY AFTER BUSINESS TYPES

            sequence [
              :contact_details,
              :postal_address
            ]
          end

          journey = DatashiftJourney.journey_plan_class.new(reference: 'UNIQUE_1234')

          expect_state_matches(journey, :new_or_renew)
          expect(journey.can_back?).to eq false # this is the initial state
          expect(journey.can_next?).to eq true
          journey.next!

          expect_state_canback_cannext_and_next!(journey, :business_type)

          # First state of a branch - We should be able to go back to the Split - based on same conditions
          expect_state_matches(journey, :other_businesses)
          expect(journey.can_back?).to eq true
          journey.back!

          expect_state_canback_cannext_and_next!(journey, :business_type)

          # Now in Sole Trader branhc
          expect_state_canback_cannext_and_next!(journey, :other_businesses)
          expect_state_canback_cannext_and_next!(journey, :service_provided)

          expect_state_matches(journey, :construction_demolition)
        end
      end
    end
  end
end
