require 'rails_helper'

module DatashiftState

  RSpec.describe JourneyPlanner do

    describe 'DSL' do

      it 'enables a complete journey to be planned via simple DSL' do

        DatashiftState::JourneyPlanner.create(:rspec_test_journey) do

          [
            :page_1,
            :page_2,
          ]

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

          [
            :review,
            :complete
          ]

        end

        journey = DatashiftState::JourneyPlanner.states(:rspec_test_journey)

        expect(journey.size).to eq 11

        expect(journey).to eq [:page_1, :page_2, :page_split, :page_1_A, :page_2_A, :page_1_B, :review, :complete]

        expect(DatashiftState::JourneyPlanner.branches(:rspec_test_journey).size).to eq 2

      end
    end
  end

end
