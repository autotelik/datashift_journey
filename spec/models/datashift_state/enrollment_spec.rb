require 'rails_helper'

RSpec.describe Registration, type: :model do

  # in dummy init we set
  #  DatashiftState.journey_plan_class = 'Registration'

  describe '#status' do
    it { is_expected.to respond_to(:state) }
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
