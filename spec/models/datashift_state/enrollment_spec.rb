require 'rails_helper'

RSpec.describe DatashiftState::JourneyPlan, type: :model do
  class Enrollment
    belongs_to :journey_plan, class_name: 'DatashiftState::JourneyPlan'
  end

  before(:all) do
    DatashiftState.journey_plan_class = 'Enrollment'
  end

  describe '#status' do
    it { is_expected.to respond_to(:status) }
  end

  describe '#token' do
    it { is_expected.to validate_presence_of(:token).on(:save) }

    it 'creates a token on creation' do
      journey_plan = described_class.new
      expect(journey_plan.token).to be_nil
      journey_plan.save
      expect(journey_plan.token).to_not be_nil
      expect(journey_plan.token.length).to eq 34
    end
  end
end
