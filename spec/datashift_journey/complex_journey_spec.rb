require 'rails_helper'

module DatashiftJourney

  module Journey

    RSpec.describe 'Complex Machine Builder Examples' do
      before(:each) do
        # N.B This is bit of a hack cos DatashiftJourney.journey_plan_class.state_machines
        # only available after at least one Machine defined
        DatashiftJourney.journey_plan_class.state_machines.clear if DatashiftJourney.journey_plan_class.respond_to?(:state_machines)
      end

      context 'Multiple Sequences' do
        it 'reports missing branches when they are not defined but are specified in split_on_equality' do
          expect {
            DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :splitter) do
              branch_sequence :renew_sequence, [:business_type]

              split_on_equality(:splitter,
                                'new_or_renew_value', # Helper method on Collector
                                new_sequence: 'new',
                                renew_sequence: 'renew')
            end
          }.to raise_exception
        end

        it 'enables the first state to be a branch splitter', ffs: true do
          DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do

            branch_sequence :new_sequence,   [:business_type]
            branch_sequence :renew_sequence, [:enter_reg_number]

            # now define the parent state and the routing criteria to each sequence

            split_on_equality(:new_or_renew,
                              'new_or_renew_value', # Helper method on TestPlanModel
                              new_sequence:   'new',
                              renew_sequence: 'renew')

            # Define the sequences for Business Type split => Partnership, Limited Company, etc

            split_on_equality(:business_type,
                              'business_type_value', # Helper method on Collector,
                              other_sequence: 'other',
                              sole_trader_sequence: 'sole_trader'
            )

            # OTHER
            branch_sequence :other_sequence, [:other_business]

            # SOLE TRADER
            branch_sequence :sole_trader_sequence, [:other_business, :service_provided]

            split_on_equality(:service_provided,
                              'service_provided_value', # Helper method on Collector
                              service_provided_no_sequence: 'no',
                              service_provided_yes_sequence: 'yes')

            branch_sequence :service_provided_no_sequence, [] # => contact_details
            branch_sequence :service_provided_yes_sequence, [:construction_demolition] # => construction_demolition

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

            sequence [:contact_details, :postal_address]
          end

          journey = DatashiftJourney.journey_plan_class.new(reference: 'UNIQUE_1234')

          expect(journey).to match_state(:new_or_renew)

          expect(journey.can_back?).to eq false       # this is the initial state so no back

          # Mimic that first form value collected from user was :new to send us down that branch
          # Until a valid value has been entered that matches a path, cannot go fwd
          expect(journey.can_skip_fwd?).to eq false
          journey.new_or_renew_value = 'new'

          expect(journey.can_skip_fwd?).to eq true
          journey.skip_fwd!

          # Inside :new_sequence so should now be on [:business_type]
          expect(journey).to match_state_can_back(:business_type)
          expect(journey.can_skip_fwd?).to eq false   # data not collected yet

          # Collect the data in this case they selected @other
          journey.business_type_value = 'other'
          expect(journey.can_skip_fwd?).to eq true
          journey.skip_fwd!

          # First state of next branch - we should be able to go back to the Split
          expect(journey).to match_state_can_back(:other_business)
          journey.back!

          expect(journey).to match_state_can_back_and_fwd(:business_type)

          # User changed selection and head down Sole Trader branch - , [:other_business, :service_provided]
          journey.business_type_value = 'sole_trader'
          journey.skip_fwd!
          expect(journey).to match_state_can_back_and_fwd(:other_business)
          journey.skip_fwd!

          expect(journey).to match_state(:service_provided)

          expect(journey.can_skip_fwd?).to eq false
          journey.service_provided_value = 'no'
          expect(journey.can_skip_fwd?).to eq true
          journey.skip_fwd!

          pending 'Think we need to maintain the last (previous) state so when we are in a common sequence, we know which of multiple branches to go back to'
          # 'no' branch is empty, so expect to go to first step of next common sequence i.e contact_details
          expect(journey).to match_state(:contact_details)
          journey.back!

          # yes branch - [:construction_demolition]
          expect(journey).to match_state(:service_provided)
          journey.service_provided_value = 'yes'
          journey.skip_fwd!

          expect(journey).to match_state_can_back_and_fwd(:construction_demolition)
          journey.skip_fwd!

          expect(journey).to match_state(:contact_details)
        end
      end
    end
  end
end
