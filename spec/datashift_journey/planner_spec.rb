require 'rails_helper'

module DatashiftJourney

  module StateMachines

    RSpec.describe Planner do
      describe 'DSL' do
        context 'Complex Sequences' do
          it 'enables a split sequence to be first item', duff: true do
            class SomeJourney
              attr_accessor :new_or_renew_value
            end

            DatashiftJourney.journey_plan_class = 'DatashiftJourney::StateMachines::SomeJourney'

            Journey::MachineBuilder.create_journey_plan_for(SomeJourney, initial: :new_or_renew) do
              # first define the sequences
              branch_sequence :new_sequence, [:new_sequence_start_page]

              branch_sequence :renew_sequence, [:renew_sequence_start_page, :enter_reg_number]

              # now define the parent state and the routing criteria to each sequence
              split_on_equality(:new_or_renew,
                                'new_or_renew_value', # Helper method on Collector
                                new_sequence: 'new',
                                renew_sequence: 'renew')
            end

            journey = DatashiftJourney.journey_plan_class.new

            # First branch
            journey.new_or_renew_value = 'new'

            expect(journey).to match_state(:new_or_renew)
            expect(journey.can_back?).to eq false # this is the initial state
            expect(journey.can_skip_fwd?).to eq true
            journey.skip_fwd!

            expect(journey).to match_state(:new_sequence_start_page)

            expect(journey.can_back?).to eq true
            expect(journey.can_skip_fwd?).to eq false # the end

            journey.back!
            expect(journey).to match_state(:new_or_renew)

            # Other branch
            journey = DatashiftJourney.journey_plan_class.new

            journey.new_or_renew_value = 'renew'

            expect(journey).to match_state(:new_or_renew)
            expect(journey.can_back?).to eq false # this is the initial state
            expect(journey.can_skip_fwd?).to eq true
            journey.skip_fwd!

            expect(journey).to match_state_can_back_and_fwd(:renew_sequence_start_page)
            expect(journey).to match_state(:enter_reg_number)

            expect(journey.can_back?).to eq true
            expect(journey.can_skip_fwd?).to eq false # the end
          end
        end

        it 'enables consecutive split sequences which all self terminate' do
          class SomeJourney1
            attr_accessor :new_or_renew_value
            attr_accessor :business_type_value
          end

          DatashiftJourney.journey_plan_class = 'DatashiftJourney::StateMachines::SomeJourney1'

          Journey::MachineBuilder.create_journey_plan(initial: :new_or_renew) do
            # test the empty sequences  - next should hit split state of next sequence ()
            branch_sequence :new_sequence, []

            branch_sequence :renew_sequence, [:renew_sequence_start_page, :enter_reg_number]

            # now define the parent state and the routing criteria to each sequence
            split_on_equality(:new_or_renew,
                              'new_or_renew_value', # Helper method on Collector
                              new_sequence: 'new',
                              renew_sequence: 'renew')

            branch_sequence :sole_trader_sequence, [:sole_trader_start]
            branch_sequence :partnership_sequence, [:partnership_start]
            branch_sequence :limited_company_sequence, [:limited_company_start]

            split_on_equality(:business_type,
                              'business_type_value',
                              sole_trader_sequence: 'sole_trader',
                              partnership_sequence: 'partnership',
                              limited_company_sequence: 'limited_company')
          end

          journey = DatashiftJourney.journey_plan_class.new

          # First branch
          journey.new_or_renew_value = 'new'

          expect(journey).to match_state(:new_or_renew)
          expect(journey.can_back?).to eq false # this is the initial state

          # new sequence is empty - use case where we just stored the split value and moved onto next sequence
          # which is :business_type
          expect(journey.can_skip_fwd?).to eq true

          journey.skip_fwd!

          expect(journey).to match_state(:business_type)
          expect(journey.can_back?).to eq true

          # We don't yet have a valid value for business_type_value so should not be able to proceed
          expect(journey.can_skip_fwd?).to eq false

          journey.business_type_value = 'partnership'

          expect(journey.can_skip_fwd?).to eq true

          journey.skip_fwd!

          expect(journey).to match_state(:partnership_start)
          expect(journey.can_back?).to eq true
          expect(journey.can_skip_fwd?).to eq false
        end
      end
    end
  end
end
