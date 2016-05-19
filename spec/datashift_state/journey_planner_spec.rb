require 'rails_helper'

module DatashiftState

  RSpec.describe Journey::Planner do

    describe 'DSL' do

      it 'enables a complete journey to be planned via simple DSL' do

        planner = Journey::Planner.new

        plan = planner.create(:rspec_test_journey) do

          sequence do
            [
              :page_1,
              :page_2
            ]
          end

          sequence :page_3, :page_4

          split_on :page_split

          split :split_A do
            [
              :page_1_A,
              :page_2_A
            ]
          end

          split :split_B do
            [
              :page_1_B
            ]
          end

          combine_on :page_come_together

          sequence  [:review, :complete ]
        end

        expect(plan).to be_a Journey::Plan

        expect(planner.plans.size).to eq 1

        expect(plan).to eq planner.plans[:rspec_test_journey]

        expect(plan.journey_proc).to be_a Proc

        states = plan.states(:rspec_test_journey)

        expect(states.size).to eq 11

        expect(states).to eq [:page_1, :page_2, :page_split, :page_1_A, :page_2_A, :page_1_B, :review, :complete]

        expect(plan.branches(:rspec_test_journey).size).to eq 2

      end
    end
  end

end
